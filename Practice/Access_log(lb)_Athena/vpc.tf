resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  for_each = {
    aza = {cidr_block="10.0.1.0/24",availability_zone="ap-northeast-2a"}
    azb = {cidr_block="10.0.2.0/24",availability_zone="ap-northeast-2b"}
  }
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-igw"
  }
}

# 2. 라우트 테이블에서 인터넷 게이트웨이로 향하는 경로 추가 (기본 라우트 테이블 사용)
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.routetable["rt1"].id
  destination_cidr_block = "0.0.0.0/0"  # 모든 트래픽
  gateway_id             = aws_internet_gateway.gw.id # 인터넷 게이트웨이
}


resource "aws_route_table" "routetable" {
  for_each = {
    rt1 = {}
  }
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "routetable_association" {
    for_each = {
      asn1 = {route_table_id=aws_route_table.routetable["rt1"].id, subnet_id=aws_subnet.subnet["aza"].id}
      asn2 = {route_table_id=aws_route_table.routetable["rt1"].id, subnet_id=aws_subnet.subnet["azb"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}

