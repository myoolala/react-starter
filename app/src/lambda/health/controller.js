/**
 * @function exports.healthcheck
 * @description Let services know we are up and running
 * @param {Express.Request} _req - Express request object
 * @param {Express.Response} res - Express response object
 */
module.exports.healthcheck = async function healthcheck(event, cache) {
	console.log('Health check endpoint hit');
	return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify('OK'),
  }
};