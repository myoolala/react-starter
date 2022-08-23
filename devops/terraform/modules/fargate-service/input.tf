variable service_name {
    type = string
    description = "Name to apply to the Fargate service"
}

variable scan_on_push {
    type = bool
    description = "Have ECR scan images on push"
    default = false
}

variable create_new_cluster {
    type = bool
    description = "Create a new cluster with the specified cluster name"
    default = true
}

variable cluster_name {
    type = string
    description = "Name of the cluster to attached the service to"
}

variable desired_count {
    type = number
    default = 2
    description = "Initial desired count of containers for the service"
}

variable image_tag {
    type = string
    description = "Version of the app in ECR to deploy"
}