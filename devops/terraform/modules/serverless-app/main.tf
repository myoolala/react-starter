module "secrets" {
  source = "../secrets"

  secrets         = var.secrets
  region          = var.region
  create_new_key  = true
  recovery_window = 0
}

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
  name = "/aws/api_gw/${aws_apigatewayv2_api.gateway.name}"

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
  path_prefix     = each.value.prefix
  secrets = {
    arns     = [for k, name in var.addition_function_configs[each.key].secrets : module.secrets.arn_map[name]]
    kms_keys = module.secrets.kms_key != null ? [module.secrets.kms_key] : []
  }
  environment_vars   = var.addition_function_configs[each.key].env_vars
  permissions        = var.addition_function_configs[each.key].permissions
  auto_deploy        = true
  create_new_gateway = false
  gateway_id         = aws_apigatewayv2_api.gateway.id
  gateway_arn        = aws_apigatewayv2_api.gateway.arn
  api_log_group      = aws_cloudwatch_log_group.api_gw.arn

  depends_on = [
    module.secrets,
    aws_s3_bucket.code_bucket,
    aws_apigatewayv2_api.gateway
  ]
}

resource "aws_lambda_permission" "api_gw" {
  for_each = var.function_configs

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.backend[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"

  depends_on = [
    module.backend
  ]
}

module "frontend_and_cache" {
  source = "../s3-site"

  create_s3_bucket = var.create_ui_bucket
  host_s3_bucket   = var.ui_bucket_name
  # If you are not using an existing ACM cert, you will need to do multiple deploys
  # The first to target only the cert to create it and validate it
  # only then can you deploy everything else
  acm_arn     = var.acm_arn
  cname       = var.cname
  s3_prefix   = var.s3_prefix
  path_to_app = var.ui_files
  apigateway_origins = [
    for stage in module.backend :
    {
      id           = stage.stage_name
      domain_name  = trimprefix(aws_apigatewayv2_api.gateway.api_endpoint, "https://")
      path_pattern = length(stage.routes) < 2 ? "${stage.path_prefix}" : "${stage.path_prefix}/*"
      stage_name   = "/${stage.stage_name}"
    }
  ]
}