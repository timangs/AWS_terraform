
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "vpc_peering_accepter" {
  provider                       = aws.singa
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.vpc_peering.id
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.vpc_peering ]
  tags = {
    Name = "vpc-peering attachment accepter"
  }
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

resource "aws_route" "singa" {
  provider = aws.singa
  route_table_id            = module.singa.rt_id
  destination_cidr_block    = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.singa.id
  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.singa ]
}
