# resource "aws_kms_key" key {

# }

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" secret {
    count = length(var.secrets)

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "secretsmanager:*"
                Effect = "Allow"
                Principal = {
                    AWS = "${data.aws_caller_identity.current.account_id}:root"
                }
                # Gross and misleading I know, but it has to be star
                # As it is attached to a single secret and AWS needs a resource line
                Resource = "*"
            }
        ]
    })
    name = var.secrets[count.index].name
    kms_key_id = var.kms_key_id
    recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" secret {
    count = length(var.secrets)

    secret_id = aws_secretsmanager_secret.secret[count.index].id
    secret_string = jsonencode(var.secrets[count.index].value)
}