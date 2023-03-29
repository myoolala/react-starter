# Required for reasons I don't understand
terraform {
  backend "s3" {}
}

module "cert" {
  source = "github.com/myoolala/terraform-aws?ref=main//cert"

  domain      = var.dns.domain
  hosted_zone = var.dns.hosted_zone
  private     = false
}

module "ui" {
  source = "github.com/myoolala/terraform-aws?ref=main//s3-site"

  create_s3_bucket = var.create_ui_bucket
  host_s3_bucket   = var.host_s3_bucket
  # If you are not using an existing ACM cert, you will need to do multiple deploys
  # The first to target only the cert to create it and validate it
  # only then can you deploy everything else
  acm_arn   = module.cert.arn
  cname     = var.dns.domain
  s3_prefix = var.s3_prefix

  depends_on = [
    module.cert
  ]
}

resource "aws_route53_record" "cname" {
  count = var.dns.hosted_zone != null && var.dns.domain != null ? 1 : 0

  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [module.ui.cloudfront_domain_name]
}