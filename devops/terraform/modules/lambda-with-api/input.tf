variable "make_new_bucket" {
  type        = bool
  description = "Is a new bucket to store the code desired"
  default     = false
}

variable "environment_vars" {
  type        = map(string)
  default     = null
  description = "Environment variables to pass into the lambda"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket the code will be stored in"
}

variable "bucket_key" {
  type        = string
  description = "S3 URI for the lambda zip file"
}

variable "lambda_name" {
  type        = string
  description = "Name for the lambda function"
}

variable "secrets" {
  type = object({
    arns     = list(string)
    kms_keys = list(string)
  })
  description = "List of secrets and associated kms keys the lambda will need access to"
  default = {
    arns     = []
    kms_keys = []
  }
}

variable "permissions" {
  type        = map(any)
  description = "Additional permissions the lambda will need"
  default     = null
}

variable "path_prefix" {
  type        = string
  description = "Common path shared between all endpoints"
}

variable "protocol" {
  type        = string
  description = "Protocol for the lambda api"
  default     = "HTTP"
}

variable "auto_deploy" {
  type        = bool
  description = "Whether updates to an API automatically trigger a new deployment"
  default     = false
}

variable "create_new_gateway" {
  type        = bool
  description = "Create a new gateway for the lambda to use"
  default     = true
}

variable "gateway_id" {
  type        = string
  description = "Id of an existing API gateway to use if you are not creating one"
  default     = null
}

variable "gateway_arn" {
  type        = string
  description = "ARN of an existing API gateway to use if you are not creating one"
  default     = null
}

variable "api_log_group" {
  type        = string
  description = "Log group name of the place to send stage logs to if a gateway was provided"
  default     = null
}

variable "endpoints" {
  type        = set(string)
  description = "List of endpoints to register to the lambda"
}