resource "aws_ecs_cluster" "cluster" {
  count = var.create_new_cluster ? 1 : 0
  name  = var.cluster_name

  # @TODO: Add support for logging
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name

  depends_on = [
    aws_ecs_cluster.cluster
  ]
}

resource "aws_ecr_repository" "service_repo" {
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

module "image" {
  source = "../task-definition"

  name         = var.service_name
  service_name = var.service_name
  image        = var.image_tag == null ? "${var.service_name}:latest" : var.image_tag
}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-fargate"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.lb_port
    to_port         = var.lb_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  # egress = [ {
  #   from_port = -1
  #   to_port = -1
  #   protocol = "tcp"
  #   cidr_blocks = "0.0.0.0/0"
  # } ]
}

resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.cluster.arn
  task_definition = module.image.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.service_subnets
    # security_groups = []
  }


  #   ordered_placement_strategy {
  #     type  = "binpack"
  #     field = "cpu"
  #   }

  #   load_balancer {
  #     target_group_arn = aws_lb_target_group.foo.arn
  #     container_name   = "mongo"
  #     container_port   = 8080
  #   }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }

  # We don't want to mess with the autoscaling
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  depends_on = [
    module.image,
    aws_lb_target_group.forwarder
  ]
}