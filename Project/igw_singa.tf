resource "aws_internet_gateway" "asi_igw" {
    provider = aws.si
  vpc_id = aws_vpc.asi_vpc.id
  tags = {
    Name = "asi_igw"
  }
}

resource "aws_route" "asi_igw_route" {
    provider = aws.si
    route_table_id            = aws_route_table.asi_routetable["apub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asi_igw.id
}