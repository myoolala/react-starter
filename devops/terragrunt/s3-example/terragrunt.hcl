terraform {
  source = "${get_terragrunt_dir()}/../../terraform//s3-site"
}

locals {
    region = "us-east-1"
}

# Indicate the input values to use for the variables of the module.
inputs = {
    create_s3_bucket = true
    host_s3_bucket = "fatrockTest"
    s3_prefix = "dev/"
    path_to_app = "${get_terragrunt_dir()}/../../../app/bin/"

  tags = {
    Environment = "dev"
  }
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
}
EOF
}