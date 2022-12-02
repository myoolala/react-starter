# Lambda Development

Here is the folder to build endpoints for the app to be ulitimately served in lambda

## Development

Each folder represents its own lambda function. Typically, one large lambda that runs all endpoints is not efficient and it's best to break it up. Possibly and probably to one lambda per endpoint. The main goal with this system is to replicate normal server development as much as possible to make transitioning between server and serverless as painless as possible. If you need to create a new lambda, just create a new folder.

## Dependencies

Add any needed dependencies for the lambdas into the package.json file located in the lambda folder. It is separated out to keep the zips as small as possible and recommended you only install what you need for the lambda and no more. Lambda by default has the aws sdk installed already.

## Routes files

This is the single biggest difference between the normal server code and the lambda code. The server code just attaches endpoints to a route. Lambda doesn't have a router, so the routes.js files primarly job is to be a config. Register a path and attach a function to it. This file is also ultimately used by terraform to register the endpoints in the api gateway and route them to the appropriate lambda code

## Index file(s)

This is the main invocation file, it sources the routes.js file to learn its options and then forwards the requests from lambda to the appropriate handler.

## Shared files

There is a shared folder for code to be shared between lambdas. The relative path is not the same between local dev and in AWS, so be sure to use the path.resolve function
when requiring a shared file

## Secrets

Out of the bos this support AWS Secrets Manager, ASM, and uses a built in cache class to lazy load secrets. If you would like to use the secrets extension, add the config.yml file 
to the desired lambda folder. That also works equally well but requires that you specify all needed secrets both in a yaml and terragrunt instead of just terragrunt

## The $default path

The API Gateway supports only 1 default endpoint no matter how many lambdas or stages you have deployed. If you plan to use a default endpoint, it is recommended you make its own
lambda for it with its own appropriate prefix. Possible all of /api or whatever may be needed if the case ever happens.

If you had to have multiple default endpoints, you would need 1 api gateway per default lambda which at the moment is not supported

### Overwriting the index.js file

If you need more specific handler behavior for a lambda, you can copy the index.js file and put it in the lambda folder. It will be used instead of the shared handler