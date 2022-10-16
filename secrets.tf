resource "aws_secretsmanager_secret" "example" {
  name_prefix = "steam-key-pair"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = jsonencode(aws_instance.steam.password_data)
}