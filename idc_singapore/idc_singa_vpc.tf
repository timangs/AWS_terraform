resource "aws_vpc" "idc-singa" {
  provider = aws.singa
  cidr_block = "10.4.0.0/16"
  # enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "idc-singa-vpc"
  }
}
resource "aws_subnet" "idc-singa" {
  provider = aws.singa
  vpc_id = aws_vpc.idc-singa.id
  cidr_block = "10.4.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "idc-singa-sn1"
  }
}
resource "aws_subnet" "idc-cgw" {
  provider = aws.singa
  vpc_id = aws_vpc.idc-singa.id
  cidr_block = "10.4.2.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "idc-singa-sn2"
  }
}
resource "aws_route_table" "idc-singa" {
  provider = aws.singa
  vpc_id = aws_vpc.idc-singa.id
  tags = {
    Name = "idc-singa-public"
  }
}
resource "aws_route_table" "idc-cgw" {
  provider = aws.singa
  vpc_id = aws_vpc.idc-singa.id
  tags = {
    Name = "idc-singa-cgw"
  }
}
resource "aws_internet_gateway" "idc-singa" {
  provider = aws.singa
  vpc_id = aws_vpc.idc-singa.id
  tags = {
    Name = "idc-singa-igw"
  }
}
resource "aws_route" "idc-singa" {
  provider = aws.singa
  route_table_id = aws_route_table.idc-singa.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.idc-singa.id
}
resource "aws_route" "idc-cgw" {
  provider = aws.singa
  route_table_id = aws_route_table.idc-cgw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.idc-singa.id
}

# module "idc-singa-igw" {
#   source = "../modules/internetgateway"
#   vpc_id = aws_vpc.idc-singa.id
#   igw_name = "idc-singa-igw"
#   route_table_id = aws_route_table.idc-singa.id
#   depends_on = [ aws_vpc.idc-singa,
#                  aws_subnet.idc-singa,
#                  aws_route_table.idc-singa ]
# }
resource "aws_route_table_association" "idc-singa" {
  provider = aws.singa
  subnet_id = aws_subnet.idc-singa.id
  route_table_id = aws_route_table.idc-singa.id
}
resource "aws_route_table_association" "idc-cgw" {
  provider = aws.singa
  subnet_id = aws_subnet.idc-cgw.id
  route_table_id = aws_route_table.idc-cgw.id
}
