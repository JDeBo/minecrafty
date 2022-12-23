resource "aws_subnet" "this" {
  vpc_id                  = data.aws_vpc.control_tower_vpc.id
  cidr_block              = cidrsubnets(data.aws_vpc.control_tower_vpc.cidr_block,2,4,4,8,8)[4]
  availability_zone       = "us-east-2a"
  # map_public_ip_on_launch = true

  tags = {
    Name  = "PublicSubnetMinecraft"
  }
}

resource "aws_route_table" "this" {
  vpc_id = data.aws_vpc.control_tower_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.control_tower_vpc.id]
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.minecraft.id
  vpc      = true
}
