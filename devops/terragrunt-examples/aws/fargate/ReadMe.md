# Fargate Deploy

This deploys the entire app in a single, immutable container with fargate. It support SSL or not at the load balancer but always prefers SSL from the load balancer to the container

## Deploying for the first time

Just running a terragrunt apply will fail. The fargate service itself depends on an image being available to pull from which can't exist until after the ECR repo is made. To fix this do:
1. From the devops container, run `terragrunt apply -target=aws_ecr_repository.service_repo` to create the ECR repo
1. Update the deploy-fargate.sh script to have its needed information to deploy
1. Not in docker, execute the deploy-fargate script `./deploy-fargate <env> <deploy tag>`

The deploy script will upload a new container image to ECR and execute the final apply to build everything

### Things to be aware of:
- Updating the load balancer from http to https or vice versa will not work due to only 1 listener allowed to be on a load balancer at a time. You can get around this by first destroying the old listener or doing the update manually