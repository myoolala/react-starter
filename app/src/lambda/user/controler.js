/**
 * @function exports.getActiveUser
 * @description Get the current logged in user
 * @param {Express.Request} req - Express request object
 * @param {Express.Response} res - Express response object
 */
module.exports.getActiveUser = function getActiveUser(event) {
	// TODO: Add error handling when adding real implementation
	return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(userService.getUser(req)),
  }
};

/**
 * @function exports.login
 * @description Attempt to login a user
 * @param {Express.Request} req - Express request object
 * @param {Express.Response} res - Express response object
 */
module.exports.login = function login(event) {
	// TODO: Implement user authentication
	return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(userService.getUser(event)),
  }
};
