terraform {
  source = "${get_terragrunt_dir()}/../../..//terraform/modules/serverless-stack"
}

locals {
    region = "us-east-1"
    environment = "dev"
    # secrets = yamldecode(sops_decrypt_file("secrets.yml"))
    function_configs = jsondecode(file("lambda.json"))
    default_env_vars = {
      LOG_LEVEL = "debug"
    }
}

# Indicate the input values to use for the variables of the module.
inputs = {
  region = local.region
  make_new_api_code_bucket = true
  code_bucket_name = "project-code-bucket"
  s3_prefix = "ui/${chomp(file("ui-tag.txt"))}"
  example_function_configs = {
    healthcheck = {
      s3Uri = "test2.zip"
      prefix = "/api/healthcheck"
      routes = ["GET /api/healthcheck"]
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
  addition_function_configs = {
    health = {
      permissions = null
      secrets = [
        "omgSuperSecretApiKey"
      ]
      env_vars = merge(local.default_env_vars, {
        
      })
    }
    user = {
      permissions = null
      secrets = []
      env_vars = merge(local.default_env_vars, {
        
      })
    }
  }
  secrets = [
    {
      name = "omgSuperSecretApiKey"
      value = "omg don't tell no one"
    },
  ]
  dns = {
    hosted_zone = "YEAHTHISAINTREAL1234"
    domain = "www.google.com"
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket = "project-state"
    key    = "personal/serverless-stack.state"
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
    }
  }
}
EOF
}