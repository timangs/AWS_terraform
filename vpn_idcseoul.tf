resource "aws_vpn_connection" "ise_cgw_vpnconnection" {
  provider = aws.se
  customer_gateway_id = aws_customer_gateway.ise_cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.se_tgw.id
  type                = "ipsec.1"
  static_routes_only = true
  tunnel1_preshared_key = "psk_timangs" 
  tunnel2_preshared_key = "psk_timangs"
  tags = {
    Name = "ise_cgw_vpnconnection"
  }
}

resource "aws_route" "ise_vpn1_route" {
  provider = aws.se
  route_table_id = aws_route_table.ise_routetable["ipub1"].id
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id = aws_instance.ise_cgw_instance.primary_network_interface_id
}