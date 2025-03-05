resource "aws_internet_gateway" "ase_igw" {
    provider = aws.se
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = "ase_igw"
  }
}

resource "aws_route" "ase_igw_route" {
    provider = aws.se
    route_table_id            = aws_route_table.ase_routetable["apub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ase_igw.id
}