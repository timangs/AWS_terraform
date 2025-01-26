resource "aws_vpc" "idc-seoul" {
  provider = aws.seoul
  cidr_block = "10.2.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "idc-seoul-vpc"
  } 
}
resource "aws_subnet" "idc-seoul" {
  provider = aws.seoul
  vpc_id = aws_vpc.idc-seoul.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "idc-seoul-sn1"
  }
}
resource "aws_route_table" "idc-seoul" {
  provider = aws.seoul
  vpc_id = aws_vpc.idc-seoul.id
  tags = {
    Name = "idc-seoul-public"
  }
}
module "idc-seoul-igw" {
  source = "../modules/internetgateway"
  vpc_id = aws_vpc.idc-seoul.id
  igw_name = "idc-seoul-igw"
  route_table_id = aws_route_table.idc-seoul.id
  depends_on = [ aws_vpc.idc-seoul,
                 aws_subnet.idc-seoul,
                 aws_route_table.idc-seoul ]
}
resource "aws_route_table_association" "idc-seoul" {
  provider = aws.seoul
  subnet_id = aws_subnet.idc-seoul.id
  route_table_id = aws_route_table.idc-seoul.id
}
