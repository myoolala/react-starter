'use-strict'

const { promisify } = require('util');
const { resolve } = require('path');
const fs = require('fs');
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const Cache = require(resolve('shared/cache'));
const ROUTES_PATTERN = process.env['ROUTES_PATTERN'] || 'routes.js';
const ENVIRONMENT = process.env['ENVIRONMENT'] || 'production';
// Load aws ahead of the handler as this can take a while to execute
const { SecretsManager } = require('aws-sdk');

const adjustRoutes = ({routes: paths, prefix}) => {
  return Object.keys(paths).reduce((agg, path) => {
    agg[path.replace(/^([A-Z]+ )/, "$1" + prefix)] = paths[path];
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
    const newRoutes = require(file);
    return {
      prefixes: agg.prefixes.concat(newRoutes.prefix),
      options: {
        ...agg.options,
        ...adjustRoutes(newRoutes)
      }
    }
  }, {
    prefixes: [],
    options: {}
  });
});

const canUseDefault = (env, path, prefixes) => env !== 'local' || !!prefixes.filter(prefix => path.startsWith(prefix)).length;

// 5 minute cache
const cache = new Cache(1000 * 60 * 5, new SecretsManager());

module.exports.handler = async (event) => {
  console.log('Event: ', event);

  let {prefixes, options} = await routes;
  const option = event.requestContext.resourceId;
  const anyOption = option.replace(/^[A-Z]+/, 'ANY');
  try {
    if (options[option]) {
      return await options[option](event, cache);
    } else if (options[anyOption]) {
      return await options[anyOption](event, cache);
    // If we are running locally, we can't just assume to use the default path if it's there. We need to
    // check the prefixes for a potential match. This is done via cloudfront when deployed so we don't
    // check when running in lambda. It wouldn't work anyway due to the lambdas getting split up
    } else if (options['$default'] && canUseDefault(ENVIRONMENT, event.requestContext.path, prefixes)) {
      return await options['$default'](event, cache);
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