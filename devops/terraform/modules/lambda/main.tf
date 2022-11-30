resource "aws_lambda_function" "function" {
  function_name = var.function_name

  s3_bucket = var.bucket
  s3_key    = var.key

  runtime = var.runtime
  handler = var.handler

  role = var.role != null ? var.role : aws_iam_role.lambda_exec[0].arn

  dynamic "environment" {
    for_each = var.environment_vars != null ? [1] : []
    content {
      variables = var.environment_vars
    }
  }

  depends_on = [
    aws_iam_role.lambda_exec
  ]
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${aws_lambda_function.function.function_name}"

  retention_in_days = var.log_retention
}

resource "aws_iam_role" "lambda_exec" {
  count = var.role == null ? 1 : 0
  name  = var.function_name

  inline_policy {
    name = "Logging"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
          Effect   = "Allow"
        }
      ]
    })
  }

  dynamic "inline_policy" {
    for_each = length(var.secrets.arns) > 0 ? [1] : []
    content {
      name = "SecretsAccess"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = concat([
          {
            Action   = "secretsmanager:GetSecretValue"
            Effect   = "Allow"
            Sid      = ""
            Resource = var.secrets.arns
          }], length(var.secrets.kms_keys) == 0 ? [] : [
          {
            Action = [
              "kms:Decrypt"
            ]
            Effect   = "Allow"
            Sid      = ""
            Resource = var.secrets.kms_keys
          }
        ])
      })
    }
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  count      = var.role != null ? 1 : 0
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}