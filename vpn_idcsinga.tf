resource "aws_vpn_connection" "isi_cgw_vpnconnection" {
  provider = aws.si
  customer_gateway_id = aws_customer_gateway.isi_cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.si_tgw.id
  type                = "ipsec.1"
  static_routes_only = true
  tunnel1_preshared_key = "psk_timangs" 
  tunnel2_preshared_key = "psk_timangs"
  tags = {
    Name = "isi_cgw_vpnconnection"
  }
}

resource "aws_route" "isi_vpn1_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.1.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}

resource "aws_route" "isi_vpn3_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.2.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}

resource "aws_route" "isi_vpn4_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.3.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}
