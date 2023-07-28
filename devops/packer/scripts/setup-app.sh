sudo mkdir /srv/app
sudo chown ubuntu:ubuntu /srv/app
mv /home/ubuntu/app/* /srv/app
sudo mkdir /var/log/app

cd /srv/app
rm -r node_modules
# npm install --omit=dev
npm install
# @TODO: Do a build with a static ui

# sudo addgroup appserver
sudo adduser appserver
# sudo usermod -a -G appserver appserver
sudo chown -R appserver:appserver /srv/app
sudo chown -R appserver:appserver /var/log/app

sudo chown root:root ~/cloudwatch-config.json
sudo mv ~/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json