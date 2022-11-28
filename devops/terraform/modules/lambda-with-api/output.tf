output "function_name" {
  value = module.lambda.function_name
}

output "stage_name" {
  value = aws_apigatewayv2_stage.lambda.name
}

output "path_prefix" {
  value = var.path_prefix
}

output "routes" {
  value = var.endpoints
}