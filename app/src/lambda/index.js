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


module.exports.handler = async (event) => {
  // console.log('Event: ', event);

  let files = (await getFiles(__dirname)).filter(file => new RegExp(ROUTES_PATTERN).test(file));
  console.log(files);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'whoops',
    }),
  }
}