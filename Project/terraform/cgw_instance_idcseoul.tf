resource "aws_customer_gateway" "ise_cgw" {
  provider = aws.se
  bgp_asn    = 65000
  ip_address = aws_eip.ise_cgwinstance_eip.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "ise_cgw"
  }
}

resource "aws_network_interface" "ise_cgwinstance_eni" {
  provider          = aws.se
  subnet_id         = aws_subnet.ise_subnet["isn2"].id
  private_ips       = ["10.2.2.100"]
  security_groups   = [aws_security_group.ise_securitygroup.id]
  source_dest_check = false
  tags = {
    Name = "ise_cgwinstance_eni"
  }
}

resource "aws_eip" "ise_cgwinstance_eip" { 
    provider = aws.se
    network_interface = aws_network_interface.ise_cgwinstance_eni.id
} 

resource "aws_instance" "ise_cgw_instance" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  key_name = var.se_key
  network_interface {
    network_interface_id = aws_network_interface.ise_cgwinstance_eni.id
    device_index = 0
  }
  tags = {
    Name = "ise_cgw_instance"
  }
  user_data = <<EOE
#!/bin/bash
yum -y install tcpdump openswan
cat <<EOF >> /etc/sysctl.conf
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
cat <<EOF > /etc/ipsec.d/aws.conf
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${aws_eip.ise_cgwinstance_eip.public_ip}
  right=${aws_vpn_connection.ise_cgw_vpnconnection.tunnel1_address}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=yes
conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${aws_eip.ise_cgwinstance_eip.public_ip}
  right=${aws_vpn_connection.ise_cgw_vpnconnection.tunnel2_address}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=yes
EOF
cat <<EOF > /etc/ipsec.d/aws.secrets
${aws_eip.ise_cgwinstance_eip.public_ip} ${aws_vpn_connection.ise_cgw_vpnconnection.tunnel1_address} ${aws_vpn_connection.ise_cgw_vpnconnection.tunnel2_address} : PSK "psk_timangs"
EOF
systemctl start ipsec
systemctl enable ipsec
EOE
}