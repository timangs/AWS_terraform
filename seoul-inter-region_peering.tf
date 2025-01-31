
resource "aws_ec2_transit_gateway_peering_attachment" "vpc_peering" {
  provider = aws.seoul
  peer_region             = "ap-southeast-1"
  transit_gateway_id      = aws_ec2_transit_gateway.seoul.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.singa.id
  tags = {
    Name = "vpc-peering attachment"
  }
}
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

resource "aws_ec2_transit_gateway_route" "seoul-idc" {
  provider = aws.seoul
  transit_gateway_route_table_id = aws_ec2_transit_gateway.seoul.association_default_route_table_id
  destination_cidr_block = "10.4.0.0/16"
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