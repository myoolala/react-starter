echo "Updating base container"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y install curl zip vim jq lsb-release software-properties-common awscli make build-essential
sudo apt-get clean all
# Download and install a version of the cloudwatch agent that doesn't depend on python
curl https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O
sudo dpkg -i -E amazon-cloudwatch-agent.deb

sudo adduser cloudwatch