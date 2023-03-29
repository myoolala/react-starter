variable "code_bucket_name" {
  type        = string
  description = "Name of the bucket to store the backend code in"
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

variable "dns" {
  type = object({
    hosted_zone = optional(string, null)
    cert        = optional(string, null)
    domain      = optional(string, null)
    private     = optional(bool, false)
  })
  description = "Any and all dns related configurations including public certificates"
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

variable "s3_prefix" {
  type        = string
  description = "Prefix path in s3 for the ui files"
  default     = "ui/latest/"
}