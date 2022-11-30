variable "make_new_lambda_bucket" {
  type        = bool
  description = "Check whether to create a new api code bucket or use an existing one"
  default     = true
}

variable "api_code_bucket_name" {
  type        = string
  description = "Name of the bucket to store the backend code in"
}

variable "protocol" {
  type        = string
  description = "Protocol for the lambda api"
  default     = "HTTP"
}

variable "service_name" {
  type        = string
  description = "Name of the application you are deploying"
}

variable "function_configs" {
  type = map(object({
    s3Uri  = string
    routes = set(string)
    prefix = string
  }))
  default     = {}
  description = "Config for all of the lambdas to produce"
}

variable "addition_function_configs" {
  type = map(object({
    permissions = map(any)
    secrets     = set(string)
    env_vars    = map(string)
  }))
  default     = {}
  description = "Addition configs for all of the lambdas to have"
}

variable "create_ui_bucket" {
  type        = bool
  default     = true
  description = "Create a new bucket to house the UI code in"
}

variable "ui_bucket_name" {
  type        = string
  description = "Name of the bucket to house the publicly reachable files"
}

variable "acm_arn" {
  type        = string
  description = "ARN of the aws cert to attach to cloudfront if desired"
  default     = null
}

variable "cname" {
  type        = string
  description = "CNAME for the site that is being hosted"
}

variable "s3_prefix" {
  type        = string
  description = "Prefix to use when storing the site in s3"

  validation {
    condition     = can(regex("^[^\\/](?:.*[^\\/])?$", var.s3_prefix))
    error_message = "No leading or trailing slashes are allowed."
  }
}

variable "ui_files" {
  type        = string
  description = "Absolute path to the files to serve via s3"
}

variable "secrets" {
  type        = list(map(string))
  default     = []
  description = "List of secrets to attach to the service"
}

variable "region" {
  type        = string
  description = "Region being deployed in AWS"
  default     = "us-east-1"
}