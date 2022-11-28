const controller = require('./controler');

module.exports = {
    prefix: "/api/user",
    routes: {
        'GET /active': controller.getActiveUser,
        'POST /login': controller.login
    }
}