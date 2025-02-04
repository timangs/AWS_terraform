resource "aws_ec2_transit_gateway_route" "ase_vpn_route" {
  provider = aws.se
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.ise_cgw_vpnconnection.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
}