variable make_new_api_code_bucket {
    type = bool
    description = "Check whether to create a new api code bucket or use an existing one"
}

variable api_code_bucket_name {
    type = string
    description = "Name of the bucket to store the backend code in"
}

variable environment_vars {
    type = map(string)
    default = {}
    description = "list of environment variables for the api"
}

variable api_bucket_uri {
    type = string
    description = "URI for the zip file for the code"
}

variable api_lambda_name {
    type = string
    description = "Name for the api lambda"
}
