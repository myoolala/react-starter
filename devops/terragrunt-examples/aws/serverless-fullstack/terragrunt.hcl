terraform {
  source = "${get_terragrunt_dir()}/../..//terraform/modules/serverless-app"
}

locals {
    region = "us-east-1"
    environment = "dev"
    # secrets = yamldecode(sops_decrypt_file("secrets.yml"))
    deploy_tag = file("deployTag.txt")
    function_configs = jsondecode(file("lambda.json"))
    default_env_vars = {
      LOG_LEVEL = "debug"
    }
}

# Indicate the input values to use for the variables of the module.
inputs = {
  vpc_id = "VPC_ID"
  region = local.region
  service_name = "react-test"
  make_new_api_code_bucket = true
  api_code_bucket_name = "NAME_FOR_THE_CODE_BUCKET"
  deploy_tag = local.deploy_tag
  example_function_configs = {
    healthcheck = {
      s3Uri = "test2.zip"
      prefix = "/api/healthcheck"
      routes = ["GET /api/healthcheck"]
      # permissions = null
      # secrets = []
      # env_vars = merge(local.default_env_vars, {
        
      # })
    },
    user = {
      s3Uri = "test2.zip"
      prefix = "/api/user"
      routes = [
        "GET /api/user/active",
        "POST /api/user/login"
      ]
    }
  }
  function_configs = local.function_configs
  create_s3_bucket = true
  ui_bucket_name = "NAME_FOR_THE_UI_BUCKET"
  # If you are not using an existing ACM cert, you will need to do multiple deploys
  # The first to target only the cert to create it and validate it
  # only then can you deploy everything else
  acm_arn = "CERT_ARN"
  cname = "ALTERNATE_CNAME"
  s3_prefix = "dev"
  ui_files = "${get_terragrunt_dir()}/../../../app/bin/"
}

# If you desire to use a remote state for multiple devs or branches
#   remote_state {
#     backend = "s3"
#     config = {
#       bucket = "mybucket"
#       key    = "path/to/my/key"
#       region = "us-east-1"
#     }
#   }

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
    }
  }
}
EOF
}