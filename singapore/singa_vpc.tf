resource "aws_vpc" "singa" {
  provider = aws.singa
  cidr_block = "10.3.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "singa-vpc"
  }
}
resource "aws_subnet" "singa" {
  provider = aws.singa
  for_each = {
    sn1 = {cidr_block="10.3.1.0/24",availability_zone="ap-southeast-1a"}
    sn3 = {cidr_block="10.3.3.0/24",availability_zone="ap-southeast-1a"}
    sn5 = {cidr_block="10.3.5.0/24",availability_zone="ap-southeast-1a"}
    sn6 = {cidr_block="10.3.6.0/24",availability_zone="ap-southeast-1a"}
  }
  vpc_id     = aws_vpc.singa.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}
resource "aws_route_table" "singa" {
  provider = aws.singa
  for_each = {
    public      = {}
    private3    = {}
    vpn         = {}
  }
  vpc_id = aws_vpc.singa.id
  tags = {
    Name = each.key
  }
}
resource "aws_internet_gateway" "singa-igw" {
    provider = aws.singa
  vpc_id = aws_vpc.singa.id
  tags = {
    Name = "singa-igw"
  }
}
resource "aws_route" "singa-igw" {
    provider = aws.singa
    route_table_id            = aws_route_table.singa["public"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.singa-igw.id
}
resource "aws_route" "singa-nat" {
  provider = aws.singa
  for_each = {
    private3 = {
      route_table_id = aws_route_table.singa["private3"].id
      network_interface_id = aws_instance.singa_pub1.primary_network_interface_id
    }
    vpn = {
      route_table_id = aws_route_table.singa["vpn"].id
      network_interface_id = aws_instance.singa_pub1.primary_network_interface_id
    }
  }
  route_table_id            = each.value.route_table_id
  destination_cidr_block    = "0.0.0.0/0"
    network_interface_id = each.value.network_interface_id
    depends_on                = [
    aws_instance.singa_pub1
    ]
}
resource "aws_route_table_association" "singa" {
  provider = aws.singa
  for_each = {
    sn1 = {subnet_id=aws_subnet.singa["sn1"].id,route_table_id=aws_route_table.singa["public"].id}
    sn3 = {subnet_id=aws_subnet.singa["sn3"].id,route_table_id=aws_route_table.singa["private3"].id}
    sn5 = {subnet_id=aws_subnet.singa["sn5"].id,route_table_id=aws_route_table.singa["vpn"].id}
    sn6 = {subnet_id=aws_subnet.singa["sn6"].id,route_table_id=aws_route_table.singa["vpn"].id}
  }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
