# 10.0.[100-103].0/24 Private Subnet 
# 10.0.[104,105].0/24 Public Subnet (route Internet Gateway)

resource "aws_subnet" "log" {
  count = 6
  vpc_id = var.vpc_id
  cidr_block = "10.0.${count.index+100}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index % 4]
  tags = {
    Name = "${var.h}sub${count.index+100}"
  }
}

resource "aws_route_table" "log" {
  count = 2
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.h}rt${count.index}"
  }
}

resource "aws_route_table_association" "log" {
  count = 4
  subnet_id = aws_subnet.log[count.index].id
  route_table_id = aws_route_table.log[0].id
}

resource "aws_route_table_association" "internet" {
  count = 2
  subnet_id = aws_subnet.log[count.index+4].id
  route_table_id = aws_route_table.log[1].id
}

resource "aws_route" "existing_igw" {
  count = var.use_existing_igw ? 1 : 0
  route_table_id = aws_route_table.log[1].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = data.aws_internet_gateway.existing_igw[0].id
}

resource "aws_internet_gateway" "igw" {
  count = var.use_existing_igw ? 0 : 1
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.h}igw"
  }
}

resource "aws_route" "igw" {
  count = var.use_existing_igw ? 0 : 1
  route_table_id = aws_route_table.log[1].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw[0].id
}

