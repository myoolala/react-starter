# Serverless Deploy

This deploys the entire app in a single, immutable, and serverless fasion with s3 and lambda. It forces SSL and requires a cert and cname

## Deploying for the first time

Just running a terragrunt apply will fail. The deploy itself depends being able to pull the relevant code. To fix this do:
1. From the devops container, run `terragrunt apply -target=aws_s3_bucket.code_bucket` to create the needed code bucket
1. Update the deploy-serverless.sh script to have its needed information to deploy
1. Not in docker, execute the deploy-serverless script `./deploy-serverless.sh <env> <deploy tag>`

The deploy script will upload all needed code and run the final apply to build everything

### Things to be aware of:
- Creating or modifying a cloudfront distro takes like 5ish minutes. Terraform hasn't hung if you see that
- If you have to recreate the distro and have a public cname pointing to it, it will fail as aws does a dns check to make sure multiple distros can't serve the same cname
- When creating new lambda endpoints, you don't need to touch terraform immediately. The deploy script pulls out the endpoints you made and registers them in terraform for you