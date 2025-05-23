resource "aws_ec2_transit_gateway_route" "ase_vpn_route" {
  provider = aws.se
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.ise_cgw_vpnconnection.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
}

resource "aws_route" "ase_vpn_route" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apub1"].id
  destination_cidr_block    = "10.2.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
}

resource "aws_route" "ase_vpn3_route" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apri3"].id
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
}

resource "aws_route" "ase_vpn4_route" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apri4"].id
  destination_cidr_block    = "10.0.0.0/8"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
}


#apri3