process.env.BABEL_ENV = 'production';
process.env.NODE_ENV = 'production';
process.traceDeprecation = true;

const path = require('path');

// Grab our webpack config
let main = require(path.resolve('src/main'));

main();
