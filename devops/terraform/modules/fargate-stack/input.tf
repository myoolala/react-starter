variable "service_name" {
  type        = string
  description = "Name to apply to the Fargate service"
}

variable "vpc_id" {
  type        = string
  description = "VPC to run the service in"
}

variable "create_new_cluster" {
  type        = bool
  description = "Create a new cluster with the specified cluster name"
  default     = true
}

variable "create_ecr_repo" {
  type        = bool
  description = "Create a new ecr repo or not"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to attached the service to"
} 

variable "image_tag" {
  type        = string
  description = "Version of the app in ECR to deploy"
  default     = null
}

variable "service_subnets" {
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

variable "lb_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
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
  type        = object({
    hosted_zone = optional(string, null)
    cert = optional(string, null)
    domain = optional(string, null)
    private = optional(bool, false)
  })
  description = "Any and all dns related configurations including public certificates"
}
