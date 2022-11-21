resource "aws_s3_bucket" "code_bucket" {
  count = var.make_new_lambda_bucket ? 1 : 0

  bucket = var.api_code_bucket_name
}

resource "aws_s3_bucket_acl" "code_bucket" {
  count  = var.make_new_lambda_bucket ? 1 : 0
  bucket = aws_s3_bucket.code_bucket[0].id

  acl = "private"
}

resource "aws_apigatewayv2_api" "gateway" {
  name          = "${var.service_name}_lambda_gw"
  protocol_type = var.protocol
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name  = "/aws/api_gw/${aws_apigatewayv2_api.gateway.name}"

  retention_in_days = 7
}

module "backend" {
  for_each = var.function_configs
  source   = "../lambda-with-api"

  make_new_bucket = false
  bucket_name     = var.api_code_bucket_name
  bucket_key      = each.value.s3Uri
  endpoints       = each.value.routes
  lambda_name     = each.key
  auto_deploy     = true
  create_new_gateway = false
  gateway_id = aws_apigatewayv2_api.gateway.id
  gateway_arn = aws_apigatewayv2_api.gateway.arn
  api_log_group = aws_cloudwatch_log_group.api_gw.arn

  depends_on = [
    aws_s3_bucket.code_bucket,
    aws_apigatewayv2_api.gateway
  ]
}