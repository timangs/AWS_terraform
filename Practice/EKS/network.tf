# networking.tf

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.instance_tags, {
    Name = "My-VPC"
  })
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(var.instance_tags, {
    Name = "My-IGW"
  })
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = merge(var.instance_tags, {
    Name = "My-Public-RT"
  })
}

resource "aws_subnet" "my_public_sn" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = local.first_available_az # Use the first available AZ
  map_public_ip_on_launch = true                     # Needed for AssociatePublicIpAddress equivalent for instances launched here

  tags = merge(var.instance_tags, {
    Name = "My-Public-SN"
  })
}

resource "aws_route_table_association" "my_public_sn_assoc" {
  subnet_id      = aws_subnet.my_public_sn.id
  route_table_id = aws_route_table.my_public_rt.id
}
