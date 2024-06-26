const path = require('path'),
	  glob = require('glob'),
	  env = require('env-var');

/**
 * @summary - Takes in a cert string that may or may not be 1 line and breaks it into a multiline 
 * string. The rhetoric is for being able to set cert strings via a script in sops which doesn't store
 * new line characters as anything but spaces
 * @param {string} cert - Cert string passed in from the environment
 * @returns a normalized cert string
 */
const normalizeCert = cert => {
	if (!cert) return cert;
	
	let [header, content] = cert.trim().split(/-\s/);
	let [body, footer] = content.split(/\s-/);
	body = body.replace(/\s/g,"\n");
	return `${header}-\n${body}\n-${footer}`;
}

/**
 * @exports
 * @description Server configurations based off either environment variables or hardcoded values
 * @summary The main idea here is to keep all containers identical, aka deploy your code to dev to
 * test it and then migrate the same image to prod. To help accomplish that, instead of using env files
 * the config file expects any info that could be different between environments to be passed in via
 * environment variables.
 */
module.exports = {
	locals: {
		title: 'React Starter',
		author: 'TODO',
		keywords: 'TODO',
		description: 'TODO',
		contentSecurityPolicy: "script-src 'self' 'unsafe-eval';style-src 'self' 'unsafe-inline'",
	},
	files: {
		routes: glob.sync(path.resolve('src/server/**/*.routes.js')),
		views: glob.sync(path.resolve('src/server/**/views')),
		lambda: path.resolve('src/lambda')
	},
	server: {
		publicDirectory: env.get('PUBLIC_DIR').default('public').asString(),
		logLevel: env.get('LOG_LEVEL').default('info').asString(),
		apiMode: env.get('API_MODE').default('DEFAULT').asString(),
		listener: {
			port: env.get('PORT').default('3000').asIntPositive(),
			enableSsl: env.get('ENABLE_SSL').default('false').asBool(),
			sslCert: normalizeCert(env.get('SSL_CERT').asString()),
			sslKey: normalizeCert(env.get('SSL_KEY').asString()),
			sslKeyPassphrase: env.get('SSL_KEY_PASSWORD').asString()
		},
		cors: {
			// @link: https://www.npmjs.com/packages/cors#configuration-options
			config: {
				// origin: "*",
				origin: false, //enable cors via this line
				methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
				preflightContinue: false,
				optionsSuccessStatus: 204,
			}
		},
		// @link: https://www.npmjs.com/package/helmet
		helmet: {
			contentSecurityPolicy: {
				useDefaults: true,
				// These are the default values if you want to change them
				directives: {
					"default-src": ["'self'"],
					"base-uri": ["'self'"],
					"font-src": ["'self'", "https: data:"],
					"form-action": ["'self'"],
					"frame-ancestors": ["'self'"],
					"img-src": ["'self'", "data:"],
					"object-src": ["'none'"],
					"script-src": ["'self'"],
					"script-src-attr": ["'none'"],
					"style-src": ["'self'",  "https: 'unsafe-inline'"],
					"upgrade-insecure-requests": []
				}
			}
		},
		session: {
			name: 'connect.id',
			// Force everyone to have a session even if they are not logged in.
			// If you are implementing login, it is better to make this false
			saveUninitialized: true,
			//Best practice, set this in your environment and use a random string of characters
			secret: env.get('SESSION_SECRET').default('6fD6pJwXBFVk6JaBRM7z').asString(), 
			resave: false,
			cookie: {
				secure: false
			}
		},
		redis: {
			enabled: env.get('ENABLE_REDIS').default('true').asBool(),
			host: env.get('REDIS_HOST').asString(),
			username: env.get('REDIS_USER').asString(),
			password: env.get('REDIS_PASSWORD').asString(),
			port: env.get('REDIS_PORT').default('6379').asIntPositive()
		}
	},
};
