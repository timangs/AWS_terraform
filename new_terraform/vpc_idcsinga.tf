resource "aws_vpc" "isi_vpc" {
  provider = aws.si
  cidr_block = "10.4.0.0/16"
  enable_dns_support = false
  tags = {
    Name = "isi_vpc"
  }
}

resource "aws_subnet" "isi_subnet" {
  provider = aws.si
  for_each = {
    isn1 = {cidr_block="10.4.1.0/24",availability_zone="ap-southeast-1a"}
    isn2 = {cidr_block="10.4.2.0/24",availability_zone="ap-southeast-1a"}
  }
  vpc_id     = aws_vpc.isi_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "isi_routetable" {
  provider = aws.si
  for_each = {
    ipub1 = {}
    ipub2 = {}
  }
  vpc_id = aws_vpc.isi_vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "isi_routetable_association" {
  provider = aws.si
    for_each = {
      isn1 = {route_table_id=aws_route_table.isi_routetable["ipub1"].id, subnet_id=aws_subnet.isi_subnet["isn1"].id}
      isn2 = {route_table_id=aws_route_table.isi_routetable["ipub2"].id, subnet_id=aws_subnet.isi_subnet["isn2"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}