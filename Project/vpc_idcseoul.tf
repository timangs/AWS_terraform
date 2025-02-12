resource "aws_vpc" "ise_vpc" {
  provider = aws.se
  cidr_block = "10.2.0.0/16"
  enable_dns_support = false
  tags = {
    Name = "ise_vpc"
  }
}

resource "aws_subnet" "ise_subnet" {
  provider = aws.se
  for_each = {
    isn1 = {cidr_block="10.2.1.0/24",availability_zone="ap-northeast-2a"}
    isn2 = {cidr_block="10.2.2.0/24",availability_zone="ap-northeast-2a"}
  }
  vpc_id     = aws_vpc.ise_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "ise_routetable" {
  provider = aws.se
  for_each = {
    ipub1 = {}
    ipub2 = {}
  }
  vpc_id = aws_vpc.ise_vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "ise_routetable_association" {
  provider = aws.se
    for_each = {
      isn1 = {route_table_id=aws_route_table.ise_routetable["ipub1"].id, subnet_id=aws_subnet.ise_subnet["isn1"].id}
      isn2 = {route_table_id=aws_route_table.ise_routetable["ipub2"].id, subnet_id=aws_subnet.ise_subnet["isn2"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}