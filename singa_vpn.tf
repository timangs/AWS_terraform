
resource "aws_vpn_gateway" "singa_vpn_gw" {
  provider = aws.singa
  vpc_id =  module.idc-singa.vpc_id
  tags = {
    Name = "singa-vpn-gw"
  }
}
resource "aws_customer_gateway" "idc-singa" {
  provider = aws.singa
  bgp_asn    = 65000
  ip_address = aws_eip.idc-singa_cgw_eip.public_ip
  type       = "ipsec.1"
  tags = {
    Name = "singa-cgw"
  }
  depends_on = [ aws_eip.idc-singa_cgw_eip ]
}
resource "aws_vpn_connection" "idc-singa" {
  provider = aws.singa
  customer_gateway_id = aws_customer_gateway.idc-singa.id
  transit_gateway_id  = aws_ec2_transit_gateway.singa.id
  type                = aws_customer_gateway.idc-singa.type #"ipsec.1"
  static_routes_only = true
  tunnel1_preshared_key = "psk_timangs" # expected length of tunnel1_preshared_key to be in the range (8 - 64), got timangs
  tags = {
    Name = "singa-vpn"
  }
}
# resource "aws_vpn_connection_route" "singa" {
#   provider = aws.singa
#   vpn_connection_id     = aws_vpn_connection.idc-singa.id
#   destination_cidr_block = "10.3.0.0/16"
# }
resource "aws_ec2_transit_gateway_route" "singa" {
  provider = aws.singa
  transit_gateway_route_table_id = aws_ec2_transit_gateway.singa.association_default_route_table_id
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.singa.id
}

resource "aws_vpn_gateway_route_propagation" "vpc2_route_propagation" {
  provider = aws.singa
  vpn_gateway_id = aws_vpn_gateway.singa_vpn_gw.id
  route_table_id = module.idc-singa.route_table_id
}


# resource "aws_route" "singa_tgw_route" {
#   provider = aws.singa
#   route_table_id         = module.idc-singa.route_table_id
#   destination_cidr_block = "10.3.0.0/16"
#   transit_gateway_id     = aws_ec2_transit_gateway.singa.id
# }

resource "aws_route" "singa_vpn_route" {
  provider = aws.singa
  route_table_id         =  module.idc-singa.route_table_id
  destination_cidr_block = "10.3.0.0/16"
  gateway_id             = aws_vpn_gateway.singa_vpn_gw.id
}


resource "aws_network_interface" "idc-singa_cgw_eni" {
  provider          = aws.singa
  subnet_id         = module.idc-singa.subnet_id
  private_ips       = ["10.4.1.50"]
  security_groups   = [module.idc-singa.security_group_id]
  source_dest_check = false
  tags = {
    Name = "idc-singa_cgw_eni"
  }
}
resource "aws_eip" "idc-singa_cgw_eip" { 
    provider = aws.singa
    network_interface = aws_network_interface.idc-singa_cgw_eni.id
} 
resource "aws_instance" "idc-singa_cgw" {
  provider = aws.singa
  ami           = var.singa-ami
  instance_type = "t2.micro"
  key_name = var.singakey
  network_interface {
    network_interface_id = aws_network_interface.idc-singa_cgw_eni.id
    device_index = 0
  }
  tags = {
    Name = "idc-singa_cgw"
  }
  user_data = <<EOE
#!/bin/bash
yum -y install tcpdump openswan
cat <<EOF>> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.ip_vti0.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
EOF
sysctl -p /etc/sysctl.conf
cat <<EOF> /etc/ipsec.d/aws.conf
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${aws_eip.idc-singa_cgw_eip.public_ip}
  right=${aws_vpn_connection.idc-singa.tunnel1_address}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.4.0.0/16
  rightsubnet=10.3.0.0/16
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
EOF
cat <<EOF> /etc/ipsec.d/aws.secrets
${aws_eip.idc-singa_cgw_eip.public_ip} ${aws_vpn_connection.idc-singa.tunnel1_address} : PSK "psk_timangs"
EOF
systemctl start ipsec
systemctl enable ipsec
hostnamectl --static set-hostname IDC-CGW
EOE
}