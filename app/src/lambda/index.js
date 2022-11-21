'use-strict'

const { promisify } = require('util');
const { resolve } = require('path');
const fs = require('fs');
const readdir = promisify(fs.readdir);
const stat = promisify(fs.stat);
const ROUTES_PATTERN = process.env['ROUTES_PATTERN'] || 'routes.js';

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
      ...require(file)
    }
  }, {});
});




module.exports.handler = async (event) => {
  console.log('Event: ', event);

  let options = await routes;
  const option = event.requestContext.resourceId;
  try {
    if (options[option]) {
      return options[option](event);
    } else if (options[event.requestContext.httpMethod + ' $default']) {
      return options[event.requestContext.httpMethod + ' $default'](event);
    }
    throw new Error('No matching endpoint found');
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