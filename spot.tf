resource "aws_spot_instance_request" "main" {
  # Persist request
  instance_interruption_behavior = "stop"
  spot_type                      = "persistent"
  wait_for_fulfillment           = true
  ami                    = data.aws_ami.debian_12.id
  instance_type          = "z1d.xlarge"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  key_name               = aws_key_pair.key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.id
  root_block_device {
    volume_size           = 60
    delete_on_termination = false
  }
  user_data                   = <<EOF
#!/bin/bash
export S3_LOCATION=s3://${aws_s3_bucket.world_files.bucket}/minecraft

# Update system and install dependencies for Debian
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip screen zsh git awscli

# Install AWS SSM Agent (Session Manager)
mkdir -p /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
cd -

# Install Java 17 on Debian
sudo apt-get install -y openjdk-17-jdk

# Add minecraft user
sudo adduser --disabled-password --gecos "" minecraft
sudo echo "minecraft ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create minecraft directories
sudo mkdir -p /opt/minecraft/backups/
sudo mkdir -p /opt/minecraft/vault/
cd /opt/minecraft/vault

# Download and install Minecraft Forge
wget -O installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.1.85/forge-1.18.2-40.1.85-installer.jar
java -jar installer.jar --installServer
rm installer.jar
mv forge*.jar server.jar

# Download and install Vault Hunters modpack
wget -O vault-hunters.zip https://media.forgecdn.net/files/4119/443/Vault+Hunters+3rd+Edition+-+0.0.1+-+Server.zip
unzip vault-hunters.zip
rm vault-hunters.zip

# Copy configuration files from S3
aws s3 cp $S3_LOCATION/ops.json .
aws s3 cp $S3_LOCATION/whitelist.json .
aws s3 cp $S3_LOCATION/server.properties .
aws s3 cp $S3_LOCATION/user_jvm_args.txt .
aws s3 cp $S3_LOCATION/server-icon.png .
echo eula=true > eula.txt

# Set permissions
sudo chown -R minecraft:minecraft /opt/minecraft/

# Set up systemd service
sudo aws s3 cp $S3_LOCATION/minecraft.service /etc/systemd/system/mc1.service
sudo systemctl enable mc1.service
sudo systemctl start mc1.service

# Install Oh My Zsh for minecraft user
runuser -u minecraft -- sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

EOF
  user_data_replace_on_change = true
  tags = {
    Name = "Minecraft"
  }
}

data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "spot" {
  instance = aws_spot_instance_request.main.spot_instance_id
}
