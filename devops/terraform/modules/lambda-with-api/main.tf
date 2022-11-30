resource "aws_s3_bucket" "code_bucket" {
  count = var.make_new_bucket ? 1 : 0

  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "code_bucket" {
  count  = var.make_new_bucket ? 1 : 0
  bucket = aws_s3_bucket.code_bucket[0].id

  acl = "private"
}

module "lambda" {
  source = "../lambda"

  environment_vars = var.environment_vars
  secrets          = var.secrets
  permissions      = var.permissions
  bucket           = var.bucket_name
  key              = var.bucket_key
  function_name    = var.lambda_name

  depends_on = [
    aws_s3_bucket.code_bucket
  ]
}

resource "aws_apigatewayv2_api" "gateway" {
  count         = var.create_new_gateway == true ? 1 : 0
  name          = "${var.lambda_name}_lambda_gw"
  protocol_type = var.protocol
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = var.create_new_gateway == true ? aws_apigatewayv2_api.gateway[0].id : var.gateway_id

  name        = "${var.lambda_name}_lambda_stage"
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = var.create_new_gateway == true ? aws_cloudwatch_log_group.api_gw[0].arn : var.api_log_group

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "proxy" {
  api_id = var.create_new_gateway == true ? aws_apigatewayv2_api.gateway[0].id : var.gateway_id

  integration_uri  = module.lambda.invoke_arn
  integration_type = "AWS_PROXY"
  # Lambda functions can only be called via a post
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "endpoint" {
  for_each = var.endpoints
  api_id   = var.create_new_gateway == true ? aws_apigatewayv2_api.gateway[0].id : var.gateway_id

  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.proxy.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  count = var.create_new_gateway == true ? 1 : 0
  name  = "/aws/api_gw/${aws_apigatewayv2_api.gateway[0].name}"

  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gw" {
  count         = var.create_new_gateway == true ? 1 : 0
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.create_new_gateway == true ? aws_apigatewayv2_api.gateway[0].execution_arn : var.gateway_arn}/*/*"
}
