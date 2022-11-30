'use-strict'

const { promisify } = require('util');
const { resolve } = require('path');
const fs = require('fs');
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const ROUTES_PATTERN = process.env['ROUTES_PATTERN'] || 'routes.js';
// Load aws ahead of the handler as this can take a while to execute
const { SecretsManager } = require('aws-sdk');

const adjustRoutes = ({routes, prefix}) => {
  return Object.keys(routes).reduce((agg, route) => {
    agg[route.replace(/^([A-Z]+ )/, "$1" + prefix)] = routes[route];
    return agg;
  }, {});
}

/** 
 * Lambda hints
 * 
 * Add any sharable logic between innvocations outside of the handler to reduce runtime
 * 
 * If you need to have lambda specific handlers, copy this file as a template into the
 * target lambda folder and you can override behavior there
 */ 

async function getFiles(dir) {
  const subdirs = await readdir(dir);
  const files = await Promise.all(subdirs.map(async (subdir) => {
    const res = resolve(dir, subdir);
    return (await stat(res)).isDirectory() ? getFiles(res) : res;
  }));
  return files.reduce((a, f) => a.concat(f), []);
}

const routes = getFiles(__dirname).then(files => {
  return files.filter(file => new RegExp(ROUTES_PATTERN).test(file));
}).then(files => {
  return files.reduce((agg, file) => {
    return {
      ...agg,
      ...adjustRoutes(require(file))
    }
  }, {});
});

/**
 * @class Cache
 * @summary: Basic cache to be shared across invocations of the lambda handler. This will save time
 * In only needing to get items out of the cache as needed vs every invocation saving time and cost
 */
class Cache {
  /**
   * 
   * @param {number} refreshTime - Time in ms for how long before an item in cache is considered too old to use
   */
  constructor(refreshTime, secretsManager) {
    this.cache = {};
    this.refreshTime = refreshTime;
    this.secretsManager = secretsManager;
  }

  /**
   * @summary - Retrieves an item out of aws secrets manager if the key is too old or not in the cache.
   * @param {string} key - Name of the secret in AWS secrets manager to pull 
   * @returns Promise<String> - Promise containing the secret even if the value is resolved
   */
  getSecret(key) {
    if (!this.cache[key] || this.cache[key].time + this.refreshTime > new Date().valueOf()) {
      this.cache[key] = {
        time: new Date().valueOf(),
        value: this.secretsManager.getSecretValue({SecretId: key}).promise().then(secret => {
          if ('SecretString' in secret) {
            return secret.SecretString;
          }
          let buff = Buffer.from(secret.SecretBinary, 'base64');
          return buff.toString('ascii');
        })
      };
    }
    return this.cache[key].value;
  }

  /**
   * @summary - Manually clears an item from the cache
   * @param {string} key - Key of the cache item to clear
   */
  clearCacheItem(key) {
    if (this.cache[key])
      delete this.cache[key];
  }

  /**
   * @summary - Resets the entire cache
   */
  clearCache() {
    delete this.cache;
    this.cache = {};
  }
}

// 5 minute cache
const cache = new Cache(1000 * 60 * 5, new SecretsManager());

module.exports.handler = async (event) => {
  console.log('Event: ', event);

  // @TODO add support for the ANY method on an endpoint
  let options = await routes;
  const option = event.requestContext.resourceId;
  try {
    if (options[option]) {
      return options[option](event, cache);
    } else if (options[event.requestContext.httpMethod + ' $default']) {
      return options[event.requestContext.httpMethod + ' $default'](event, cache);
    }
    console.error('No matching endpoint found');
    return;
  } catch (e) {
    console.error(e);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'An error has occured',
      }),
    }
  }
}