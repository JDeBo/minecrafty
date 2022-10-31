resource "aws_secretsmanager_secret" "example" {
  name_prefix = "steam-key-pair"
}

# resource "aws_secretsmanager_secret_version" "example" {
#   secret_id     = aws_secretsmanager_secret.example.id
#   secret_string = base64decode(aws_instance.steam.password_data)
# }

resource "aws_key_pair" "key_pair" {
  key_name   = "terraform_key"
  public_key = var.public_key
}