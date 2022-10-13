resource "aws_key_pair" "key_pair" {
  key_name   = "terraform_key"
  public_key = var.rsa_public_key
}

resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "Allow RDP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "RDP TCP from Anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP UPD from Anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}