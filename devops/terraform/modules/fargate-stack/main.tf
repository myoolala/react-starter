# Required for reasons I don't understand
terraform {
  backend "s3" {}
}

module "fargate_service" {
    source = "github.com/myoolala/terraform-aws?ref=main//fargate-service"

    service_name = var.service_name
    vpc_id = var.vpc_id
    scan_on_push = false
    create_new_cluster = true
    create_ecr_repo = true
    certificate_arn = var.dns.cert == null ? module.cert.arn : var.dns.cert
    cluster_name = var.cluster_name
    container_port = 3000
    image_tag = var.image_tag
    service_subnets = var.service_subnets
    loadbalancer_subnets = var.loadbalancer_subnets
    region = var.region
    lb_ingress_cidr = var.lb_ingress_cidr
    log_retention = var.log_retention
    secrets = var.secrets
    env_vars = {
        
    }

    depends_on = [
      module.cert
    ]
}

module "cert" {
    source = "github.com/myoolala/terraform-aws?ref=main//cert"

    domain = var.dns.domain
    hosted_zone = var.dns.hosted_zone
    private = false
}

resource "aws_route53_record" "cname" {
    count = var.dns.hosted_zone != null && var.dns.domain != null ? 1 : 0

  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [module.fargate_service.cname_target]
}

