terraform {
  cloud {
    organization = "jdebo-automation"
    workspaces {
      name = "steam-server"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "control_tower_vpc" {
  filter {
    name   = "tag:Name"
    values = ["aws-controltower-VPC"]
  }
}

data "aws_ami" "windows_2021" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

#   owners = ["137112412989"] # AWS
}

resource "aws_instance" "lab" {
  ami                    = data.aws_ami.windows_2021.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]
  subnet_id              = aws_subnet.this.id

  tags = {
    Name = "Steam Server"
  }
}
