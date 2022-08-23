variable cpu {
    type = number
    default = 1
    description = "CPU value to give to the docker definition"
}

variable memory {
    type = number
    default = 512
    description = "Memory amount in MB to give to the docker definition"
}

variable port_mappings {
    type = list(map)
    default = [
        {
            containerPort = 443
            hostPort = 443
        }
    ]
}