process.env.BABEL_ENV = 'production';
process.env.NODE_ENV = 'production';
process.traceDeprecation = true;

const path = require('path');

let main = require(path.resolve('src/main'));

main();
