variable make_new_bucket {
    type = bool
    description = "Is a new bucket to store the code desired"
    default = false
}

variable environment_vars {
    type = map(string)
    default = null
    description = "Environment variables to pass into the lambda"
}

variable bucket_name {
  type = string
  description = "Name of the bucket the code will be stored in"
}

variable bucket_key {
    type = string
    description = "S3 URI for the lambda zip file"
}

variable lambda_name {
    type = string
    description = "Name for the lambda function"
}

variable protocol {
    type = string
    description = "Protocol for the lambda api"
    default = "HTTP"
}

variable auto_deploy {
    type = bool
    description = "Whether updates to an API automatically trigger a new deployment"
    default = false
}