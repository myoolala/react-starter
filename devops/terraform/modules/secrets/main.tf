# resource "aws_kms_key" key {

# }

resource "aws_secretsmanager_secret" secret {
    count = length(var.secrets)

    name = var.secrets[count.index].name
    kms_key_id = var.kms_key_id
    recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" secret {
    count = length(var.secrets)

    secret_id = aws_secretsmanager_secret.secret[count.index].id
    secret_string = jsonencode(var.secrets[count.index].value)
}