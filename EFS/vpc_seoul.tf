resource "aws_vpc" "ase_vpc" {
  provider = aws.se
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "ase_vpc"
  }
}

resource "aws_vpc" "ase_vpc1" {
  provider = aws.se
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "ase_vpc1"
  }
}

resource "aws_subnet" "ase_subnet" {
  provider = aws.se
  for_each = {
    asn1 = {cidr_block="10.0.1.0/24",availability_zone="ap-northeast-2a"}
    asn2 = {cidr_block="10.0.2.0/24",availability_zone="ap-northeast-2b"}
    asn3 = {cidr_block="10.0.3.0/24",availability_zone="ap-northeast-2c"}
  }
  vpc_id     = aws_vpc.ase_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "ase_subnet1" {
  provider = aws.se
  for_each = {
    asn1-2 = {cidr_block="10.1.1.0/24",availability_zone="ap-northeast-2a"}
  }
  vpc_id     = aws_vpc.ase_vpc1.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}


resource "aws_route_table" "ase_routetable" {
  provider = aws.se
  for_each = {
    apub1 = {}
    # apri3 = {}
    # apri4 = {}
    # avpn5 = {}
    # avpn6 = {}
  }
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = each.key
  }
}


resource "aws_route_table" "ase_routetable1" {
  provider = aws.se
  for_each = {
    apub2 = {}
  }
  vpc_id = aws_vpc.ase_vpc1.id
  tags = {
    Name = each.key
  }
}


resource "aws_route_table_association" "ase_routetable_association" {
  provider = aws.se
    for_each = {
      asn1 = {route_table_id=aws_route_table.ase_routetable["apub1"].id, subnet_id=aws_subnet.ase_subnet["asn1"].id}
      asn2 = {route_table_id=aws_route_table.ase_routetable["apub1"].id, subnet_id=aws_subnet.ase_subnet["asn2"].id}
      asn3 = {route_table_id=aws_route_table.ase_routetable["apub1"].id, subnet_id=aws_subnet.ase_subnet["asn3"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}


resource "aws_route_table_association" "ase_routetable_association1" {
  provider = aws.se
    for_each = {
      asn1 = {route_table_id=aws_route_table.ase_routetable1["apub2"].id, subnet_id=aws_subnet.ase_subnet1["asn1-2"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}



resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = aws_vpc.ase_vpc.id
  vpc_id        = aws_vpc.ase_vpc1.id
  auto_accept = true 
  tags = {
      Name = "vpc-peering"
  }
}

resource "aws_route" "vpc1_to_vpc2" {
  route_table_id            = aws_vpc.ase_vpc.main_route_table_id
  destination_cidr_block    = aws_vpc.ase_vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "vpc2_to_vpc1" {
  route_table_id            = aws_vpc.ase_vpc1.main_route_table_id
  destination_cidr_block    = aws_vpc.ase_vpc.cidr_block 
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_instance" "ase_instance_web1" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.1.30"
  subnet_id = aws_subnet.ase_subnet["asn1"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_web1"
  }
  user_data = <<EOF
#!/bin/bash
# echo "toor" | passwd --stdin root
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance ase_instance_web1</h1>" > /var/www/html/index.html
EOF
}


resource "aws_instance" "ase_instance_web2" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.1.31"
  subnet_id = aws_subnet.ase_subnet["asn1"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_web2"
  }
  user_data = <<EOF
#!/bin/bash
# echo "toor" | passwd --stdin root
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance ase_instance_web2</h1>" > /var/www/html/index.html
EOF
}


resource "aws_instance" "ase_instance_web3" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.3.30"
  subnet_id = aws_subnet.ase_subnet["asn3"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_web3"
  }
  user_data = <<EOF
#!/bin/bash
# echo "toor" | passwd --stdin root
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance ase_instance_web3</h1>" > /var/www/html/index.html
EOF
}

resource "aws_instance" "ase1_instance_web1" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.1.1.30"
  subnet_id = aws_subnet.ase_subnet1["asn1-2"].id
  security_groups = [aws_security_group.ase_securitygroup1.id]
  tags = {
    Name = "ase1_instance_web1"
  }
  user_data = <<EOF
#!/bin/bash
# echo "toor" | passwd --stdin root
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance ase1_instance_web1</h1>" > /var/www/html/index.html
EOF
}