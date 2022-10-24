variable cpu {
    type = number
    default = 256
    description = "CPU value to give to the docker definition"
}

variable name {
    type = string
    description = "Name to assign to the new task definition"
}

variable service_name {
    type = string
    description = "Name of the service to associate the definition with"
}

variable memory {
    type = number
    default = 512
    description = "Memory amount in MB to give to the docker definition"
}

variable port_mappings {
    type = list(map(number))
    default = [
        {
            containerPort = 443
            hostPort = 443
        }
    ]
}

variable image {
    type = string
    description = "Container image to attach to the task defition"
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to all resources. Ie: environment, cost tracking, etc..."
  default     = {}
}