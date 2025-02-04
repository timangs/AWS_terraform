resource "aws_route" "ase_route3_tgw" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apub1"].id
  destination_cidr_block    = "10.3.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
resource "aws_route" "ase_route4_tgw" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apub1"].id
  destination_cidr_block    = "10.4.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}

####################################################################################
resource "aws_route" "asi_route1_tgw" {
  provider = aws.si
  route_table_id            = aws_route_table.asi_routetable["apub1"].id
  destination_cidr_block    = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}

resource "aws_route" "asi_route2_tgw" {
  provider = aws.si
  route_table_id            = aws_route_table.asi_routetable["apub1"].id
  destination_cidr_block    = "10.2.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
