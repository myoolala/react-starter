#!/bin/bash

output() {
    local black='\033[0;30m'
    local red='\033[0;31m'
    local green='\033[0;32m'
    local yellow='\033[0;33m'
    local blue='\033[0;34m'
    local magenta='\033[0;35m'
    local cyan='\033[0;36m'
    local lightgrey='\033[0;37m'
    local white='\033[1;37m'
    local NC='\033[0m'
    local color="${!1}"
    local text=$2
    echo -e "${color}$text${NC}"
}

if [ ! -d "/root/repo/devops" ]; then
    echo "This is only meant to run in the devops container"
    echo "Please run \"docker-compose run devops tg-init\""    
    exit 1
fi

if echo "$@" | grep -q -e "--help"; then
    output green "Hope this helped"
    exit 0
fi

output green "Starting initialization process for the devops folder"

output white "Are you initializing aws, gcp, or azure?"
read;

if [[ "$REPLY" != "aws" &&  "$REPLY" != "gcp" && "$REPLY" != "azure" ]]; then
    output red "Invalid environment selected, aborting"
    exit 1
fi

if [ ! -d "/root/repo/devops/terragrunt" ]; then
    output green "No terragrunt file found, making one"
    mkdir "/root/repo/devops/terragrunt"
fi

output green "Copying, but not overwriting, example hcl files"
cp -r -n /root/repo/devops/terragrunt-examples/$REPLY /root/repo/devops/terragrunt/$REPLY 