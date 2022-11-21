const controller = require('./controler');

module.exports = {
    'GET /api/user/active': controller.getActiveUser,
    'POST /api/user/login': controller.login
}