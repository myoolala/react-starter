variable "stack_identifier" {
  type        = string
  description = "Name to apply to the Fargate service"
}

variable "vpc_id" {
  type        = string
  description = "VPC to run the service in"
}

variable "env" {
  type        = string
  description = "Name of the cluster to attached the service to"
}

variable "ami" {
  type        = string
  description = "Version of the app in ECR to deploy"
  default     = null
}

variable "asg_subnets" {
  type        = list(string)
  description = "Subnets to run the service in"
}

variable "loadbalancer_subnets" {
  type        = list(string)
  description = "Subnets to run the load balancer in (public/private)"
}

variable "region" {
  type        = string
  description = "Region to deploy the service to"
}

variable "lb_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Number of days to store the service logs for"
}

variable "secrets" {
  type        = list(map(string))
  default     = []
  description = "List of secrets to attach to the service"
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

variable "ssh" {
  type = object({
    key      = optional(string, null)
    key_name = optional(string, null)
    ips      = optional(list(string), null)
  })
  description = "SSH key access config"
  default     = {}
}