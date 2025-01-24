resource "aws_instance" "seoul_pub1" {
  provider = aws.seoul
  ami           = var.seoul-nat-ami
  source_dest_check = false
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.1.1.100"
  key_name = var.seoulkey
  subnet_id = aws_subnet.seoul["sn1"].id
  security_groups = [aws_security_group.seoul.id]
  tags = {
    Name = "seoul_pub1"
  }
  user_data = <<EOF
#!/bin/bash
yum -y install tcpdump iptraf
hostname Se-NAT-10-1-1-100
EOF
}

resource "aws_instance" "seoul_pub2" {
  provider = aws.seoul
  ami           = var.seoul-nat-ami
  source_dest_check = false
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.1.2.100"
  key_name = var.seoulkey
  subnet_id = aws_subnet.seoul["sn2"].id
  security_groups = [aws_security_group.seoul.id]
  tags = {
    Name = "seoul_pub2"
  }
  user_data = <<EOF
#!/bin/bash
yum -y install tcpdump iptraf
hostname Se-NAT-10-1-2-100
EOF
}

resource "aws_instance" "seoul_pri1" {
  provider = aws.seoul
  ami           = var.seoul-ami
  instance_type = "t2.micro"
  # associate_public_ip_address = "true"
  private_ip = "10.1.3.100"
  subnet_id = aws_subnet.seoul["sn3"].id
  security_groups = [aws_security_group.seoul.id]
  tags = {
    Name = "seoul_pri1"
  }
  user_data = <<EOF
#!/bin/bash
echo "toor" | passwd --stdin root
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Private Instance 1</h1>" > /var/www/html/index.html
hostname Se-Private-10-1-3-100
EOF
}

resource "aws_instance" "seoul_pri2" {
  provider = aws.seoul
  ami           = var.seoul-ami
  instance_type = "t2.micro"
  # associate_public_ip_address = "true"
  private_ip = "10.1.4.100"
  subnet_id = aws_subnet.seoul["sn4"].id
  security_groups = [aws_security_group.seoul.id]
  tags = {
    Name = "seoul_pri2"
  }
  user_data = <<EOF
#!/bin/bash
echo "toor" | passwd --stdin root
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Private Instance 2</h1>" > /var/www/html/index.html
hostname Se-Private-10-1-4-100
EOF
}