variable make_new_bucket {
    type = bool
    description = "Is a new bucket to store the code desired"
    default = false
}

variable environment_vars {
    type = map(string)
    default = {}
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
