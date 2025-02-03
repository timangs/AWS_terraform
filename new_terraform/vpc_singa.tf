resource "aws_vpc" "asi_vpc" {
  provider = aws.si
  enable_dns_hostnames = true
  cidr_block = "10.3.0.0/16"
  tags = {
    Name = "vpc_asi"
  }
}

resource "aws_subnet" "asi_subnet" {
  provider = aws.si
  for_each = {
    asn1 = {cidr_block="10.3.1.0/24",availability_zone="ap-southeast-1a"}
    asn3 = {cidr_block="10.3.3.0/24",availability_zone="ap-southeast-1a"}
    asn5 = {cidr_block="10.3.5.0/24",availability_zone="ap-southeast-1a"}
    asn6 = {cidr_block="10.3.6.0/24",availability_zone="ap-southeast-1c"}
  }
  vpc_id     = aws_vpc.asi_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "asi_routetable" {
  provider = aws.si
  for_each = {
    apub1 = {}
    apri3 = {}
    adns5 = {}
  }
  vpc_id = aws_vpc.asi_vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "asi_routetable_association" {
  provider = aws.si
    for_each = {
      asn1 = {route_table_id=aws_route_table.asi_routetable["apub1"].id, subnet_id=aws_subnet.asi_subnet["asn1"].id}
      asn3 = {route_table_id=aws_route_table.asi_routetable["apri3"].id, subnet_id=aws_subnet.asi_subnet["asn3"].id}
      asn5 = {route_table_id=aws_route_table.asi_routetable["adns5"].id, subnet_id=aws_subnet.asi_subnet["asn5"].id}
      asn6 = {route_table_id=aws_route_table.asi_routetable["adns5"].id, subnet_id=aws_subnet.asi_subnet["asn6"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}