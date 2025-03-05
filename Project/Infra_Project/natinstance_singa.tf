resource "aws_route" "asi_nat3_route" {
  provider = aws.si
  route_table_id = aws_route_table.asi_routetable["apri3"].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.asi_instance_nat1.primary_network_interface_id
  depends_on = [ aws_instance.asi_instance_nat1 ]
}

resource "aws_instance" "asi_instance_nat1" {
  provider = aws.si
  ami           = var.si_nat_ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.3.1.100"
  key_name = var.si_key
  subnet_id = aws_subnet.asi_subnet["asn1"].id
  security_groups = [aws_security_group.asi_securitygroup.id]
  tags = {
    Name = "asi_instance_nat1"
  }
  depends_on = [ aws_internet_gateway.asi_igw ]
  user_data = <<EOF
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
yum -y install tcpdump
EOF
}