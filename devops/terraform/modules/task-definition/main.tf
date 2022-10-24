resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name         = var.name
      image        = var.image
      cpu          = var.cpu
      memory       = var.memory
      essential    = true
      portMappings = var.port_mappings
    }
  ])

  # Uncomment if desired but for most apps this isn't necessary
  #   volume {
  #     name      = "service-storage"
  #     host_path = "/ecs/service-storage"
  #   }

  # Uncomment if desired but for most apps this isn't necessary
  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }

  tags = merge(var.tags, {
  })
}