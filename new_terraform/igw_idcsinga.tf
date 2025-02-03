resource "aws_internet_gateway" "isi_igw" {
    provider = aws.si
  vpc_id = aws_vpc.isi_vpc.id
  tags = {
    Name = "isi_igw"
  }
}

resource "aws_route" "isi_igw_route1" {
    provider = aws.se
    route_table_id            = aws_route_table.isi_routetable["ipub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isi_igw.id
}

resource "aws_route" "isi_igw_route2" {
    provider = aws.se
    route_table_id            = aws_route_table.isi_routetable["ipub2"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isi_igw.id
}