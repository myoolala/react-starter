variable "host_s3_bucket" {
  type        = string
  description = "Name of the bucket to store the backend code in"
}

variable "create_ui_bucket" {
  type        = bool
  description = "Create a new bucket for the ui files"
  default     = true
}

variable "dns" {
  type = object({
    hosted_zone = optional(string, null)
    domain      = optional(string, null)
    private     = optional(bool, false)
  })
  description = "Any and all dns related configurations including public certificates"
}

variable "s3_prefix" {
  type        = string
  description = "Prefix path in s3 for the ui files"
  default     = "ui/latest/"
}