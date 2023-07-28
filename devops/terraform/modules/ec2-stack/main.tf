# Required for reasons I don't understand
terraform {
  backend "s3" {}
}

module "asg" {
  source = "github.com/myoolala/terraform-aws?ref=main//asg-service"
  name   = var.stack_identifier
  network = {
    vpc     = var.vpc_id
    subnets = var.asg_subnets
    ingresses = var.ssh.ips != null ? [{
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh.ips
    }] : []
  }
  capacity = {
    min = 0
    desired = 0
    max = 2
  }
  config = {
    health_check_type = "EC2"
  }
  ami           = var.ami
  instance_type = "t3.micro"
  lb = {
    subnets = var.loadbalancer_subnets
    port_mappings = [{
      listen_port  = 443
      forward_port = 3000
      tg_protocol = "HTTP"
      cert         = var.dns.cert == null ? module.cert.arn : var.dns.cert
      # health_check = {

      # }
    }]
  }
  key_name = var.ssh.key != null ? aws_key_pair.debug_key[0].key_name : var.ssh.key_name
  env_vars = {
    LOG_LEVEL = "debug"
    # PORT = 3001
  }
  user_data = {
    pre_env = <<EOF
touch /var/log/app/node.log
sed -i -E 's/"log_group_name": "[^"]*"/"log_group_name": "react-asg"/g' /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
sudo chown appserver:appserver /var/log/app/node.log
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
sudo su - appserver
EOF
    post_env = <<EOF
cd /srv/app
whoami
# cp /tmp/env.sh ./
# chown appserver:appserver env.sh
# source env.sh
# pm2 start "npm run prod"
npm run start >> /var/log/app/node.log 2>> /var/log/app/node.log
EOF
  }


  depends_on = [
    module.cert
  ]
}

resource "aws_key_pair" "debug_key" {
  count = var.ssh.key != null ? 1 : 0

  key_name   = "${var.stack_identifier}-debugging-key"
  public_key = var.ssh.key
}

module "cert" {
  source = "github.com/myoolala/terraform-aws?ref=main//cert"

  domain      = var.dns.domain
  hosted_zone = var.dns.hosted_zone
  private     = false
}

resource "aws_route53_record" "cname" {
  count = var.dns.hosted_zone != null && var.dns.domain != null ? 1 : 0

  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [module.asg.cname_target]
}
