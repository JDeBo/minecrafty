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

resource "aws_ec2_serial_console_access" "true" {
  enabled = true
}

data "aws_ami" "linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # AWS
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.linux_2.id
  instance_type          = "z1d.large"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  key_name               = aws_key_pair.key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.id
  # java-17-amazon-corretto < Java 17
  # java-1.8.0-openjdk < Java 8
  user_data                   = <<EOF
#!/bin/bash
export S3_LOCATION=s3://${aws_s3_bucket.world_files.bucket}/minecraft
sudo yum update -y
sudo yum install java-17-amazon-corretto screen zsh git -y
sudo adduser minecraft
sudo echo "minecraft ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "${random_password.ec2_password.result}" | sudo passwd minecraft --stdin
sudo mkdir /opt/minecraft/
sudo mkdir /opt/minecraft/backups/
sudo mkdir /opt/minecraft/vault/
cd /opt/minecraft/vault
wget -O installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.1.85/forge-1.18.2-40.1.85-installer.jar
java -jar installer.jar --installServer
rm installer.jar
mv forge*.jar server.jar
wget -O vault-hunters.zip https://media.forgecdn.net/files/4119/443/Vault+Hunters+3rd+Edition+-+0.0.1+-+Server.zip
unzip vault-hunters.zip
rm vault-hunters.zip
aws s3 cp $S3_LOCATION/ops.json .
aws s3 cp $S3_LOCATION/whitelist.json .
aws s3 cp $S3_LOCATION/server.properties .
aws s3 cp $S3_LOCATION/user_jvm_args.txt .
aws s3 cp $S3_LOCATION/server-icon.png .
echo eula=true > eula.txt
sudo chown -R minecraft:minecraft /opt/minecraft/
sudo aws s3 cp $S3_LOCATION/minecraft.service /etc/systemd/system/mc1.service
sudo systemctl enable mc1.service
sudo systemctl start mc1.service
runuser -u minecraft -- sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

EOF
  user_data_replace_on_change = true

  tags = {
    Name = "Minecrafty Server"
  }
  depends_on = [
    aws_s3_bucket.world_files
  ]
}
