resource "aws_internet_gateway" "idc_igw" {
    provider = aws.se
  vpc_id = aws_vpc.idc_vpc.id
  tags = {
    Name = "idc_igw"
  }
}

resource "aws_internet_gateway" "aws_igw" {
    provider = aws.se
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name = "aws_igw"
  }
}

resource "aws_route" "idc_igw_route" {
    provider = aws.se
    route_table_id            = aws_route_table.idc_routetable["ipub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.idc_igw.id
}

resource "aws_route" "aws_igw_route" {
    provider = aws.se
    route_table_id            = aws_route_table.aws_routetable["apub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
}