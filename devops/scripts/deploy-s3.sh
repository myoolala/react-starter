#!/bin/bash

logYellow() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    echo -e "${YELLOW}$@${NC}"
}

if [[ "$1" == "test" ]]; then
    tg_location="devops/terragrunt/aws/s3"
    s3_ui_path="project-ui-files/"
else
    logYellow "Please enter a valid environment to use"
    exit 1
fi

current_tag="$2"
if [[ "$2" == "" ]]; then
    current_tag="$(git rev-parse HEAD)"
    logYellow "No optional tag provided, using the git commit: $current_tag"
fi

logYellow "Building the UI"
cd ../../
docker-compose build app
docker-compose run app s3-build

if [ $? -ne 0 ]; then
    logYellow "NPM build failed."
    exit 1
fi

logYellow "Pushing UI code to S3"
docker-compose run devops bash -c "aws s3 cp /root/repo/app/bin s3://$s3_ui_path$current_tag --recursive"
echo -n $current_tag > $tg_location/ui-tag.txt

docker-compose run -w /root/repo/$tg_location devops bash -c "terragrunt apply"
