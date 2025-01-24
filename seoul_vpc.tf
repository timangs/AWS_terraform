resource "aws_vpc" "seoul" {
  provider = aws.seoul
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "seoul-vpc"
  }
}
resource "aws_subnet" "seoul" {
  provider = aws.seoul
  for_each = {
    sn1 = {cidr_block="10.1.1.0/24",availability_zone="ap-northeast-2a"}
    sn2 = {cidr_block="10.1.2.0/24",availability_zone="ap-northeast-2c"}
    sn3 = {cidr_block="10.1.3.0/24",availability_zone="ap-northeast-2a"}
    sn4 = {cidr_block="10.1.4.0/24",availability_zone="ap-northeast-2c"}
    sn5 = {cidr_block="10.1.5.0/24",availability_zone="ap-northeast-2a"}
  }
  vpc_id     = aws_vpc.seoul.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}
resource "aws_route_table" "seoul" {
  for_each = {
    public      = {}
    private3    = {}
    private4    = {}
    tgw         = {}
  }
  provider = aws.seoul
  vpc_id = aws_vpc.seoul.id
  tags = {
    Name = each.key
  }
}
module "igw" {
  source = "./modules/internetgateway"
  vpc_id = aws_vpc.seoul.id
  igw_name = "seoul-igw"
  route_table_id = aws_route_table.seoul["public"].id
}
resource "aws_route_table_association" "seoul" {
  provider = aws.seoul
  for_each = {
    sn1 = {subnet_id=aws_subnet.seoul["sn1"].id,route_table_id=aws_route_table.seoul["public"].id}
    sn2 = {subnet_id=aws_subnet.seoul["sn2"].id,route_table_id=aws_route_table.seoul["public"].id}
    sn3 = {subnet_id=aws_subnet.seoul["sn3"].id,route_table_id=aws_route_table.seoul["private3"].id}
    sn4 = {subnet_id=aws_subnet.seoul["sn4"].id,route_table_id=aws_route_table.seoul["private4"].id}
    sn5 = {subnet_id=aws_subnet.seoul["sn5"].id,route_table_id=aws_route_table.seoul["tgw"].id}
  }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
resource "aws_security_group" "seoul" {
  provider = aws.seoul
  name   = "seoul_sg"
  vpc_id = aws_vpc.seoul.id
  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 53, to_port = 53, protocol = "udp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 53, to_port = 53, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 4500, to_port = 4500, protocol = "udp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route" "nat" {
  for_each = {
    private3 = {
      route_table_id = aws_route_table.seoul["private3"].id
      destination_cidr_block = "0.0.0.0/0"
      network_interface_id = aws_instance.seoul_pub1.primary_network_interface_id
    }
    private4 = {
      route_table_id = aws_route_table.seoul["private4"].id
      destination_cidr_block = "0.0.0.0/0"
      network_interface_id = aws_instance.seoul_pub2.primary_network_interface_id
    }
  }
  provider = aws.seoul
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
  network_interface_id = each.value.network_interface_id
  depends_on                = [aws_instance.seoul_pub2]
}