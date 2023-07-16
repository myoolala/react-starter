# Required for reasons I don't understand
terraform {
  backend "s3" {}
}

module "fargate_service" {
  source = "github.com/myoolala/terraform-aws?ref=main//fargate-service"

  service_name = var.service_name
  network = {
    vpc_id  = var.vpc_id
    subnets = var.service_subnets
  }
  cluster = {
    name   = var.cluster_name
    create = true
  }
  ecr = {
    create       = true
    scan_on_push = false
  }
  image_tag = var.image_tag
  region    = var.region
  log_retention = var.log_retention
  secrets       = var.secrets
  env_vars = {

  }
  lb = {
    subnets = var.loadbalancer_subnets
    port_mappings = [{
      listen_port  = 443
      forward_port = 3000
      cert         = var.dns.cert == null ? module.cert.arn : var.dns.cert
      # health_check = {

      # }
    },]
  }

  depends_on = [
    module.cert
  ]
}

module "cert" {
  source = "github.com/myoolala/terraform-aws?ref=main//cert"

  domain      = var.dns.domain
  hosted_zone = var.dns.hosted_zone
  private     = false
}

resource "aws_route53_record" "cname" {
  count = var.dns.hosted_zone != null && var.dns.domain != null ? 1 : 0

  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [module.fargate_service.cname_target]
}

