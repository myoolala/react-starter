#!/bin/bash

logYellow() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m'
    echo -e "${YELLOW}$@${NC}"
}

if [[ "$1" == "test" ]]; then
    tg_location="devops/terragrunt/aws/serverless-stack"
    s3_bucket="project-code-bucket"
    s3_backend_prefix="lambdas/"
    s3_backend_uri="$s3_bucket/$s3_backend_prefix"
    s3_ui_path="$s3_bucket/ui/"
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

logYellow "Cleaning out old zip files"
rm devops/builds/lambdas/*.zip
cd app/src/lambda

logYellow "Installing dependencies"
npm install --omit=dev

logYellow "Building new zip files"
for f in $(ls -d */); do
    file="$(echo $f | grep -oE "[^/]+")"
    if [ "$file" == "node_modules" ] || [ "$file" == "shared" ]; then
        continue
    fi
    logYellow "Creating $file lambda zip"

    if test -f "$(pwd)/${file}/index.js"; then
        overwriteFile=false
    else
        overwriteFile=true
    fi

    # Build each lambda which involves moving the shared files to each folder prior to zip
    cp -n index.js ./$file/
    mv ./shared ./$file/
    cd $file
    mv ../node_modules ./
    zipFile="$current_tag-$file.zip"
    zip -q -r $zipFile ./*
    mv ./shared ../
    mv ./node_modules ../

    if [[ "$overwriteFile" == "true" ]]; then
        rm "index.js"
    fi

    # copy all the zips into one folder so we only need to start docker for a single copy command
    cp -p $zipFile ../../../../devops/builds/lambdas/
    rm $zipFile
    cd ..
done
rm -r ./node_modules

logYellow "Copying new lambda zips to S3"
docker-compose run devops bash -c "aws s3 cp /root/repo/devops/builds/lambdas/ s3://$s3_backend_uri --recursive --exclude \"*\" --include \"*.zip\""

logYellow "Generating new lambda config for terraform"
# @TODO: Is it worth making an entrypoint for the devops container to avoid these problems of environment?
docker-compose run -w /root/repo/app devops bash -c "source ~/.bashrc && npm run get-lambda-config $current_tag \"$s3_backend_prefix\" /root/repo/$tg_location/lambda.json"
docker-compose run -w /root/repo/$tg_location devops bash -c "echo $current_tag > ./deployTag.txt"
docker-compose run -w /root/repo/$tg_location devops bash -c "terragrunt apply"

