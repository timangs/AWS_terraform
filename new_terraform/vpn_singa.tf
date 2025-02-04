resource "aws_ec2_transit_gateway_route" "asi_vpn_route" {
  provider = aws.si
  destination_cidr_block         = "10.4.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.isi_cgw_vpnconnection.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.si_tgw.association_default_route_table_id
}

resource "aws_route" "asi_vpn_route" {
  provider = aws.si
  route_table_id            = aws_route_table.asi_routetable["apub1"].id
  destination_cidr_block    = "10.4.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
}