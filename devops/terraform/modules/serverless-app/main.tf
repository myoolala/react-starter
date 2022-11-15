module backend {
    source = "../lambda-api"

    make_new_bucket = var.make_new_api_code_bucket
    bucket_name = var.api_code_bucket_name
    environment_vars = var.environment_vars
    bucket_key = var.api_bucket_uri
    lambda_name = var.api_lambda_name
}