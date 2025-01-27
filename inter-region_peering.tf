resource "aws_ec2_transit_gateway_vpc_attachment" "seoul" {
  provider = aws.seoul
  subnet_ids = [
    module.seoul.subnet1_id,
    module.seoul.subnet2_id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.seoul.id
  vpc_id = module.seoul.vpc_id
  tags = {
    Name = "seoul-tgw-attachment"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "singa" {
  provider = aws.singa
  subnet_ids = [module.singa.subnet1_id]
  transit_gateway_id = aws_ec2_transit_gateway.singa.id
  vpc_id = module.singa.vpc_id
  tags = {
    Name = "singa-tgw-attachment"
  }
}
resource "aws_ec2_transit_gateway_peering_attachment" "vpc_peering" {
  provider = aws.seoul
  peer_region             = "ap-southeast-1"
  transit_gateway_id      = aws_ec2_transit_gateway.seoul.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.singa.id
  tags = {
    Name = "vpc-peering attachment"
  }
}
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "vpc_peering_accepter" {
  provider                       = aws.singa
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.vpc_peering.id
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.vpc_peering ]
  tags = {
    Name = "vpc-peering attachment accepter"
  }
}
# resource "aws_ec2_transit_gateway_route_table" "seoul" {
#   provider = aws.seoul
#   transit_gateway_id = aws_ec2_transit_gateway.seoul.association_default_route_table_id
#   tags = {
#     Name = "seoul-tgw-rt"
#   }
#   depends_on = [ aws_ec2_transit_gateway_vpc_attachment.seoul ]
# }
# resource "aws_ec2_transit_gateway_route_table" "singa" {
#   provider = aws.singa
#   transit_gateway_id = aws_ec2_transit_gateway.singa.association_default_route_table_id
#   tags = {
#     Name = "singa-tgw-rt"
#   }
#   depends_on = [ aws_ec2_transit_gateway_vpc_attachment.singa ]
# }
resource "aws_ec2_transit_gateway_route" "seoul" {
  provider = aws.seoul
  transit_gateway_route_table_id = aws_ec2_transit_gateway.seoul.association_default_route_table_id
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.vpc_peering.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.vpc_peering,
    aws_ec2_transit_gateway_peering_attachment_accepter.vpc_peering_accepter
  ]
}
resource "aws_ec2_transit_gateway_route" "singa" {
  provider = aws.singa
  transit_gateway_route_table_id = aws_ec2_transit_gateway.singa.association_default_route_table_id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.vpc_peering.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.vpc_peering,
    aws_ec2_transit_gateway_peering_attachment_accepter.vpc_peering_accepter
  ]
}

resource "aws_route" "seoul" {
  provider = aws.seoul
  route_table_id            = module.seoul.rt_id
  destination_cidr_block    = "10.3.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.seoul.id
  depends_on                = [aws_ec2_transit_gateway_vpc_attachment.seoul]
}

resource "aws_route" "singa" {
  provider = aws.singa
  route_table_id            = module.singa.rt_id
  destination_cidr_block    = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.singa.id
  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.singa ]
}
