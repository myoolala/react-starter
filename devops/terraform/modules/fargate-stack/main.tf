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
    certificate_arn = var.dns.cert != null ? var.dns.cert : aws_acm_certificate.cert[0].arn
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
      aws_acm_certificate.cert,
      aws_acm_certificate_validation.cert
    ]
}

resource "aws_acm_certificate" "cert" {
    count = var.dns.domain != null ? 1 : 0

  domain_name       = var.dns.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
data "aws_route53_zone" "cert" {
    count = var.dns.hosted_zone != null ? 1 : 0
  name         = var.dns.hosted_zone
  private_zone = var.dns.private
}

resource "aws_route53_record" "cert" {
  for_each = var.dns.domain == null ? {} : {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cert[0].zone_id
}

resource "aws_acm_certificate_validation" "cert" {
    count = var.dns.domain != null ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}

resource "aws_route53_record" "cname" {
    count = var.dns.domain != null ? 1 : 0

  zone_id = data.aws_route53_zone.cert[0].zone_id
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [module.fargate_service.cname_target]
}

