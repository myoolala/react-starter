# Required for reasons I don't understand
terraform {
  backend "s3" {}
}

module "app" {
  source = "github.com/myoolala/terraform-aws?ref=main//serverless-app"

  make_new_lambda_bucket    = true
  api_code_bucket_name      = var.code_bucket_name
  protocol                  = "HTTP"
  service_name              = "react-starter"
  function_configs          = var.function_configs
  addition_function_configs = var.addition_function_configs
  create_ui_bucket          = false
  ui_bucket_name            = var.code_bucket_name
  # acm_arn = var.dns.cert == module.cert.arn : var.dns.cert
  acm_arn   = module.cert.arn
  cname     = var.dns.domain
  s3_prefix = "ui"
  secrets   = var.secrets
  region    = var.region

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
  records = [module.app.cloudfront_domain_name]
}