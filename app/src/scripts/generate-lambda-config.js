'use-strict'

const { resolve, dirname } = require('path');
const { readdir, stat, writeFile } = require('fs/promises');
const ROUTES_PATTERN = process.env['ROUTES_PATTERN'] || 'routes.js';

async function getFiles(dir) {
  const subdirs = await readdir(dir);
  const files = await Promise.all(subdirs.map(async (subdir) => {
    const res = resolve(dir, subdir);
    return (await stat(res)).isDirectory() ? getFiles(res) : res;
  }));
  return files.reduce((a, f) => a.concat(f), []);
}

(async args => {
    let output = args.pop();
    let s3Prefix = args.pop();
    let hash = args.pop();
    let mappings = await getFiles(resolve(__dirname, "../lambda")).then(files => {
        return files.filter(file => new RegExp(ROUTES_PATTERN).test(file));
    }).then(files => {
        return files.reduce((agg, file) => {
            let data = require(file);
            let key = dirname(file).split('/').pop();
            data.s3Uri = `${s3Prefix}${hash}-${key}.zip`;
            data.routes = Object.keys(data.routes).map(route => route.replace(/(^[^ ]+ )/, `$1${data.prefix}`));
            agg[key] = data;
            return agg;
        }, {});
    });
    console.log(JSON.stringify(mappings, null, 4));
    await writeFile(resolve(output), JSON.stringify(mappings));
})(process.argv).then(() =>{
    process.exit();
}, err =>{
    console.error(err);
    process.exit(1);
});