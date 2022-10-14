resource "aws_subnet" "this" {
  vpc_id                  = data.aws_vpc.control_tower_vpc.id
  cidr_block              = cidrsubnet(data.aws_vpc.control_tower_vpc.cidr_block, 4, 2)
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "PublicSubnetSteam"
  }
}

resource "aws_route_table" "this" {
  vpc_id = data.aws_vpc.control_tower_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = data.aws_vpc.control_tower_vpc.id

  tags = {
    Name = "Public Subnet IG"
  }
}