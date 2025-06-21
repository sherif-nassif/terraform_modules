resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet1" {
  availability_zone       = var.az_1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = "true"

  tags = {
    Name = var.subnet1_name
  }
}

resource "aws_subnet" "public_subnet2" {
  availability_zone       = var.az_2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = "true"

  tags = {
    Name = var.subnet2_name
  }
}

resource "aws_route_table" "routing" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.route
    gateway_id = aws_internet_gateway.gw.id
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.routing.id
}


resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.routing.id
}