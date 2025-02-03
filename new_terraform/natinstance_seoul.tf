resource "aws_route" "ase_nat3_route" {
  provider = aws.se
  route_table_id = aws_route_table.ase_routetable["apri3"].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.ase_instance_nat1.primary_network_interface_id
  depends_on = [ aws_instance.ase_instance_nat1 ]
}

resource "aws_route" "ase_nat4_route" {
  provider = aws.se
  route_table_id = aws_route_table.ase_routetable["apri4"].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.ase_instance_nat2.primary_network_interface_id
  depends_on = [ aws_instance.ase_instance_nat2 ]
}


resource "aws_instance" "ase_instance_nat1" {
  provider = aws.se
  ami           = var.se_nat_ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.1.1.100"
  key_name = var.se_key
  subnet_id = aws_subnet.ase_subnet["asn1"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_nat1"
  }
  depends_on = [ aws_internet_gateway.ase_igw ]
  user_data = <<EOF
#!/bin/bash
yum -y install tcpdump iptraf
EOF
}

resource "aws_instance" "ase_instance_nat2" {
  provider = aws.se
  ami           = var.se_nat_ami
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.1.2.100"
  key_name = var.se_key
  subnet_id = aws_subnet.ase_subnet["asn2"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_nat2"
  }
  depends_on = [ aws_internet_gateway.ase_igw ]
  user_data = <<EOF
#!/bin/bash
yum -y install tcpdump iptraf
EOF
}