const controller = require('./controller');

module.exports = {
    'GET /api/healthcheck': controller.healthcheck
}