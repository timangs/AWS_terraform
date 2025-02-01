
# resource "aws_vpn_gateway" "seoul_vpn_gw" {
#   provider = aws.seoul
#   vpc_id =  module.idc-seoul.vpc_id
#   tags = {
#     Name = "seoul-vpn-gw"
#   }
# }
resource "aws_customer_gateway" "idc-seoul" {
  provider = aws.seoul
  bgp_asn    = 65001
  ip_address = aws_eip.idc-seoul_cgw_eip.public_ip
  type       = "ipsec.1"
  tags = {
    Name = "seoul-cgw"
  }
}
resource "aws_vpn_connection" "idc-seoul" {
  provider = aws.seoul
  customer_gateway_id = aws_customer_gateway.idc-seoul.id
  transit_gateway_id  = aws_ec2_transit_gateway.seoul.id
  type                = aws_customer_gateway.idc-seoul.type #"ipsec.1"
  static_routes_only = true
  # vpn_gateway_id = aws_vpn_gateway.seoul_vpn_gw.id
  tunnel1_preshared_key = "psk_timangs" 
  tunnel2_preshared_key = "psk_timangs"
  local_ipv4_network_cidr = "10.2.0.0/16"
  remote_ipv4_network_cidr = "10.1.0.0/16"
  tags = {
    Name = "seoul-vpn"
  }
}
resource "aws_ec2_transit_gateway_route" "idc-seoul" {
  provider = aws.seoul 
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.idc-seoul.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.seoul.association_default_route_table_id
}

resource "aws_route" "seoul-vpn-route" {
  provider = aws.seoul
  route_table_id            = module.seoul.rt_id
  destination_cidr_block    = "10.2.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.seoul.id
  depends_on                = [aws_ec2_transit_gateway_vpc_attachment.seoul]
}

resource "aws_network_interface" "idc-seoul_cgw_eni" {
  provider          = aws.seoul
  subnet_id         = module.idc-seoul.subnet_id
  private_ips       = ["10.2.1.50"]
  security_groups   = [module.idc-seoul.security_group_id]
  source_dest_check = false
  tags = {
    Name = "idc-seoul_cgw_eni"
  }
}
resource "aws_eip" "idc-seoul_cgw_eip" { 
    provider = aws.seoul
    network_interface = aws_network_interface.idc-seoul_cgw_eni.id
} 
resource "aws_instance" "idc-seoul_cgw" {
  provider = aws.seoul
  ami           = var.seoul-ami
  instance_type = "t2.micro"
  key_name = var.seoulkey
  network_interface {
    network_interface_id = aws_network_interface.idc-seoul_cgw_eni.id
    device_index = 0
  }
  tags = {
    Name = "idc-seoul_cgw"
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
  leftid=${aws_eip.idc-seoul_cgw_eip.public_ip}
  right=${aws_vpn_connection.idc-seoul.tunnel1_address}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.1.0.0/16
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=yes
conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${aws_eip.idc-seoul_cgw_eip.public_ip}
  right=${aws_vpn_connection.idc-seoul.tunnel2_address}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.1.0.0/16
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=yes
EOF
cat <<EOF> /etc/ipsec.d/aws.secrets
${aws_eip.idc-seoul_cgw_eip.public_ip} ${aws_vpn_connection.idc-seoul.tunnel1_address} ${aws_vpn_connection.idc-seoul.tunnel2_address} : PSK "psk_timangs"
EOF
systemctl start ipsec
systemctl enable ipsec
hostnamectl --static set-hostname seoul-CGW
EOE
}