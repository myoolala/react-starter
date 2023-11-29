#!/bin/bash

logYellow() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    text="$@"
    echo "${YELLOW}" "$text" "${NC}"
}

cd ../..

if [[ "$1" == "example" ]]; then
    dockerfile="pureNode.production"
    tg_location="/root/repo/devops/terragrunt/aws/fargate"
    ecr_repo="react-test"
    region="us-east-1"
    aws_account_id="4372189748"
else
    logYellow "Please enter a valid environment to use"
    exit 1
fi

current_tag="$2"
if [[ "$2" == "" ]]; then
    current_tag="$(git rev-parse HEAD)"
    logYellow "No optional tag provided, using the git commit: $current_tag"
fi

logYellow "Building image"
aws_image="$aws_account_id.dkr.ecr.$region.amazonaws.com/$ecr_repo:$current_tag"
# This is the old method that does gzip compression. This is fine but AWS is now optimized to work zstd compression
# docker build --platform linux/amd64 -f "app/dockerfiles/$dockerfile" -t $current_tag ./app

docker buildx build \
  --platform linux/amd64 \
  --file "app/dockerfiles/$dockerfile" \
  --output type=image,name=$aws_image,oci-mediatypes=true,compression=zstd,compression-level=3,force-compression=true,push=false ./app

if [[ "$?" != "0" ]]; then
    logYellow "Error during docker build, aborting"
    exit 1
fi

logYellow "Deploying \"$ecr_repo:$current_tag\". Is that correct? y/n"
read;

if [[ "$REPLY" != "y" ]]; then
    logYellow "Aborting"
    exit 0
fi

logYellow "Pushing the image to ECR"
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$aws_account_id.dkr.ecr.$region.amazonaws.com"
docker tag $current_tag $aws_image
docker push "$aws_image"

logYellow "Updating the terragrunt configs. REMEMBER TO COMMIT THIS"
docker-compose build devops
sed_tag="$aws_account_id.dkr.ecr.$region.amazonaws.com\\/$ecr_repo:$current_tag"
docker-compose run -w $tg_location devops bash -c "sed -i -E 's/^( +image_tag += +).+$/\1\"$sed_tag\"/g' terragrunt.hcl"

logYellow "Starting the deployment"
docker-compose run -w $tg_location devops bash -c "terragrunt init"
docker-compose run -w $tg_location devops bash -c "terragrunt apply"