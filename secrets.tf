resource "aws_secretsmanager_secret" "minecraft" {
  name_prefix = "minecraft-pwd"
}

resource "random_password" "ec2_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "minecraft" {
  secret_id     = aws_secretsmanager_secret.minecraft.id
  secret_string = random_password.ec2_password.result
}

resource "aws_key_pair" "key_pair" {
  key_name   = "minecraft_key"
  public_key = var.public_key
}