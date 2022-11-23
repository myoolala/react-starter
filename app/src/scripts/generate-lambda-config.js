'use-strict'

const { promisify } = require('util');
const { resolve, dirname } = require('path');
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

const configs = getFiles(resolve(__dirname, "../lambda")).then(files => {
  return files.filter(file => new RegExp(ROUTES_PATTERN).test(file));
}).then(files => {
  return files.reduce((agg, file) => {
    let data = require(file);
    data.folder = dirname(file);
    data.routes = Object.keys(data.routes);
    return agg.concat([data]);
  }, []);
});

(async () => {
    let mappings = await configs;
    console.log(JSON.stringify(mappings));
})().then(() =>{
    process.exit();
}, err =>{
    console.error(err);
    process.exit(1);
});