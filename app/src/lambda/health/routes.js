const controller = require('./controller');

modules.exports = {
    'GET /api/healthcheck': controller.healthcheck
}