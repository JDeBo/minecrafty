resource "aws_spot_instance_request" "main" {
  # Persist request
  instance_interruption_behavior = "stop"
  spot_type                      = "persistent"
  wait_for_fulfillment           = true
  valid_until                    = time_offset.ami_update.rfc3339

  ami                    = time_offset.ami_update.triggers.ami_id
  instance_type          = "z1d.xlarge"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  key_name               = aws_key_pair.key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.id
  root_block_device {
    volume_size           = 40
    delete_on_termination = false
  }
  tags = {
    Name = "Minecrafty Spotty"
  }
}

data "aws_ami" "spot" {
#   executable_users = ["self"]
  most_recent      = true
  #   name_regex       = "^minecrafty-\\d{3}"
  owners = ["self"]

  filter {
    name   = "name"
    values = ["minecrafty-*"]
  }
}

resource "time_offset" "ami_update" {
  triggers = {
    # Save the time each switch of an AMI id
    ami_id = data.aws_ami.spot.id
  }

  offset_days = 35
}

resource "aws_eip" "spotter" {
  instance = aws_spot_instance_request.main.spot_instance_id
  vpc      = true
}
