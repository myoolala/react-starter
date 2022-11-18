const controller = require('./controler');

modules.exports = {
    'GET /api/user/active': controller.getActiveUser,
    'POST /api/user/login': controller.login
}