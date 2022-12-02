const controller = require('./controller');

module.exports = {
    prefix: '/api/healthcheck',
    routes: {
        'GET ': controller.healthcheck
    }
}