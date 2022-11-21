variable "make_new_lambda_bucket" {
  type        = bool
  description = "Check whether to create a new api code bucket or use an existing one"
  default = true
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
  type = string
  description = "Name of the application you are deploying"
}

variable "function_configs" {
  type = map(object({
    s3Uri  = string
    routes = set(string)
  }))
  default     = {}
  description = "Config for all of the lambdas to produce"
}
