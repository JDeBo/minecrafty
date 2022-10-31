resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "Allow RDP inbound traffic"
  vpc_id      = data.aws_vpc.control_tower_vpc.id

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