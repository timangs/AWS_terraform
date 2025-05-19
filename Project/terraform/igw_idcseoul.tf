resource "aws_internet_gateway" "ise_igw" {
    provider = aws.se
  vpc_id = aws_vpc.ise_vpc.id
  tags = {
    Name = "ise_igw"
  }
}

resource "aws_route" "ise_igw_route1" {
    provider = aws.se
    route_table_id            = aws_route_table.ise_routetable["ipub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ise_igw.id
}

resource "aws_route" "ise_igw_route2" {
    provider = aws.se
    route_table_id            = aws_route_table.ise_routetable["ipub2"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ise_igw.id
}