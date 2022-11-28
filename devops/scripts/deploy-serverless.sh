#!/bin/bash

logYellow() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    echo -e "${YELLOW}$@${NC}"
}

if [[ "$1" == "test" ]]; then
    tg_location="<TG_LOCATION>"
    s3_bucket="<S3_BUCKET_TO_DEPLOY_LAMBDA_CODE_TO_WITH_THIS_ENDING_SLASH>/"
    s3_prefix="<S3_PREFIX_IF_YOU_NEST_THE_FUNCTIONS_IN_FOLDERS>"
    s3_uri="$s3_bucket$s3_prefix"
else
    logYellow "Please enter a valid environment to use"
    exit 1
fi

current_tag="$2"
if [[ "$2" == "" ]]; then
    current_tag="$(git rev-parse HEAD)"
    logYellow "No optional tag provided, using the git commit: $current_tag"
fi

# This is the UI built and ready to deploy
# @TODO fix this so a user doesn't need to build the ui first to do any TG updates
logYellow "Building the UI"
docker-compose build app
docker-compose run app s3-build

if [ $? -ne 0 ]; then
    logYellow "NPM build failed."
    exit 1
fi

logYellow "Cleaning out old zip files"
rm ../builds/lambdas/*.zip
cd ../../app/src/lambda

logYellow "Building new zip files"
for file in $(ls -d */); do
    if test -f "$(pwd)/${file}index.js"; then
        overwriteFile=false
    else
        overwriteFile=true
    fi

    cp -n index.js ./$file
    cd $file
    zipFile="$current_tag-$(echo $file | grep -oE "[^/]+").zip"
    zip $zipFile ./*

    if [[ "$overwriteFile" == "true" ]]; then
        rm "index.js"
    fi

    cp -p $zipFile ../../../../devops/builds/lambdas/
    rm $zipFile
    cd ..
done

logYellow "Copying new lambda zips to S3"
docker-compose run devops bash -c "aws s3 cp /root/repo/devops/builds/lambdas/ s3://$s3_uri --recursive --exclude \"*\" --include \"*.zip\""

logYellow "Generating new lambda config for terraform"
# @TODO: Is it worth making an entrypoint for the devops container to avoid these problems of environment?
docker-compose run -w /root/repo/app devops bash -c "source ~/.bashrc && npm run get-lambda-config $current_tag \"$s3_prefix\" $tg_location/lambda.json"
docker-compose run -w $tg_location devops bash -c "terragrunt apply"

