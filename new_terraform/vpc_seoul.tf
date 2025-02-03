resource "aws_vpc" "ase_vpc" {
  provider = aws.se
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "ase_vpc"
  }
}

resource "aws_subnet" "ase_subnet" {
  provider = aws.se
  for_each = {
    asn1 = {cidr_block="10.1.1.0/24",availability_zone="ap-northeast-2a"}
    asn2 = {cidr_block="10.1.2.0/24",availability_zone="ap-northeast-2c"}
    asn3 = {cidr_block="10.1.3.0/24",availability_zone="ap-northeast-2a"}
    asn4 = {cidr_block="10.1.4.0/24",availability_zone="ap-northeast-2c"}
    asn5 = {cidr_block="10.1.5.0/24",availability_zone="ap-northeast-2a"}
    asn6 = {cidr_block="10.1.6.0/24",availability_zone="ap-northeast-2c"}
  }
  vpc_id     = aws_vpc.ase_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "ase_routetable" {
  provider = aws.se
  for_each = {
    apub1 = {}
    apri3 = {}
    apri4 = {}
    adns5 = {}
    adns6 = {}
  }
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "ase_routetable_association" {
  provider = aws.se
    for_each = {
      asn1 = {route_table_id=aws_route_table.ase_routetable["apub1"].id, subnet_id=aws_subnet.ase_subnet["asn1"].id}
      asn2 = {route_table_id=aws_route_table.ase_routetable["apub1"].id, subnet_id=aws_subnet.ase_subnet["asn2"].id}
      asn3 = {route_table_id=aws_route_table.ase_routetable["apri3"].id, subnet_id=aws_subnet.ase_subnet["asn3"].id}
      asn4 = {route_table_id=aws_route_table.ase_routetable["apri4"].id, subnet_id=aws_subnet.ase_subnet["asn4"].id}
      asn5 = {route_table_id=aws_route_table.ase_routetable["adns5"].id, subnet_id=aws_subnet.ase_subnet["asn5"].id}
      asn6 = {route_table_id=aws_route_table.ase_routetable["adns6"].id, subnet_id=aws_subnet.ase_subnet["asn6"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}