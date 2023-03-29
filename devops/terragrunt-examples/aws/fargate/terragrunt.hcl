terraform {
  source = "${get_terragrunt_dir()}/../../..//terraform/modules/fargate-stack"
}

locals {
    region = "us-east-1"
    environment = "dev"
    secrets = yamldecode(sops_decrypt_file("secrets.yml"))
}

# Indicate the input values to use for the variables of the module.
inputs = {
  vpc_id = "VPC_ID"
  cluster_name = local.environment
  region = local.region
  service_name = "react-starter"
  create_ecr_repo = true
  image_tag = "latest"
  container_port = 80
  service_protocol = "HTTP"
  service_subnets = [
    "subnet-1",
    "subnet-2"
  ]
  loadbalancer_subnets = [
    "subnet-3",
    "subnet-4"
  ]
  lb_protocol = "HTTPS"
  lb_port = 443
  desired_count = 1
  dns = {
    hosted_zone = "YEAHTHISAINTREAL1234"
    domain = "www.google.com"
  }
  secrets = [
    {
      name = "internalTrafficCert"
      value = local.secrets.ssl.cert
      env_name = "SSL_CERT"
    },
    {
      name = "internalTrafficKey"
      value = local.secrets.ssl.key
      env_name = "SSL_KEY"
    },
    {
      name = "internalTrafficPassphrase"
      value = local.secrets.ssl.passphrase
      env_name = "SSL_KEY_PASSWORD"
    },
  ]
}

remote_state {
  backend = "s3"
  config = {
    bucket = "project-state"
    key    = "personal/fargate-stack.state"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "project-state-lock"
  }
}

# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "${local.region}"
  default_tags {
    tags = {
      Environment = "${local.environment}"
      Billing = "${local.environment}"
    }
  }
}
EOF
}