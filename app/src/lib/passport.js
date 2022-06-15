/**
 * @function initialize
 * @description Setup and configure passport
 * @param passport <Object> - Passport object to assign sessions to
 */
module.exports.initialize = function initialize(passport) {
	passport.serializeUser((user, done) => {
		done(null, user.id);
	});

	passport.deserializeUser((id, done) => {
		// TODO
		done();
	});

	// TODO: Load any strategies
};
