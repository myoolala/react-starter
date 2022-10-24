variable "service_name" {
  type        = string
  description = "Name to apply to the Fargate service"
}

variable "vpc_id" {
  type        = string
  description = "VPC to run the service in"
}

variable "scan_on_push" {
  type        = bool
  description = "Have ECR scan images on push"
  default     = false
}

variable "create_new_cluster" {
  type        = bool
  description = "Create a new cluster with the specified cluster name"
  default     = true
}

variable "lb_protocol" {
  type    = string
  default = "HTTPS"
}

variable "service_protocol" {
  type    = string
  default = "HTTPS"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of a cert to attached to attach ot the load balancer"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to attached the service to"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "lb_port" {
  type    = number
  default = 443
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "Initial desired count of containers for the service"
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

variable "tags" {
  type        = map(any)
  description = "Tags to apply to all resources. Ie: environment, cost tracking, etc..."
  default     = {}
}

variable "lb_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}