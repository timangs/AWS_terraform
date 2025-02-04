resource "aws_ec2_transit_gateway_route" "se_tgw_route3" {
  provider = aws.se
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
resource "aws_ec2_transit_gateway_route" "se_tgw_route4" {
  provider = aws.se
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
####################################################################################################################################
resource "aws_ec2_transit_gateway_route" "si_tgw_route1" {
  provider = aws.si
  transit_gateway_route_table_id = aws_ec2_transit_gateway.si_tgw.association_default_route_table_id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
resource "aws_ec2_transit_gateway_route" "si_tgw_route2" {
  provider = aws.si
  transit_gateway_route_table_id = aws_ec2_transit_gateway.si_tgw.association_default_route_table_id
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
