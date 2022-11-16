resource "aws_s3_bucket" code_bucket {
    count = var.make_new_bucket ? 1 : 0
    
    bucket = var.bucket_name
}

resource aws_s3_bucket_acl code_bucket {
    count = var.make_new_bucket ? 1 : 0
    bucket = aws_s3_bucket.code_bucket[0].id

    acl = "private"
}

module lambda {
    source = "../lambda"

    environment_vars = var.environment_vars
    bucket = var.bucket_name
    key = var.bucket_key
    function_name = var.lambda_name

    depends_on = [
      aws_s3_bucket.code_bucket
    ]
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "${var.lambda_name}_lambda_gw"
  protocol_type = var.protocol
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "${var.lambda_name}_lambda_stage"
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

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

resource "aws_apigatewayv2_integration" proxy {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = module.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" get_endpoint {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.proxy.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
