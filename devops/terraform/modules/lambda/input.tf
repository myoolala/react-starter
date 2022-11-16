variable "role" {
  type        = string
  description = "Existing role to attach to the lambda if desired"
  default     = null
}

variable "function_name" {
  type        = string
  description = "Name for the new lambda function"
}

variable "bucket" {
  type        = string
  description = "Name of the bucket to pull the code from"
}

variable "key" {
  type        = string
  description = "S3 Key of the source zip file"
}

variable "runtime" {
  type        = string
  description = "Runtime to use for the lambda"
  default     = "nodejs16.x"
}

variable "handler" {
  type        = string
  description = "Handler function"
  default     = "index.handler"
}

variable "log_retention" {
  type        = number
  description = "Number in days to store logs in cloudwatch"
  default     = 7
}

variable "environment_vars" {
  type        = map(string)
  default     = null
  description = "Environment variables to pass into the lambda"
}