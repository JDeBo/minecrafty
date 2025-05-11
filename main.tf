terraform {
  cloud {
    organization = "jdebo-automation"
    workspaces {
      name = "minecraft-server"
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

