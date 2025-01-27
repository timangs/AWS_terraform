resource "aws_instance" "singa_pub1" {
  provider = aws.singa
  ami           = var.singa-nat-ami
  source_dest_check = false
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.3.1.100"
  key_name = var.singakey
  subnet_id = aws_subnet.singa["sn1"].id
  security_groups = [aws_security_group.singa.id]
  tags = {
    Name = "singa_pub1"
  }
  user_data = <<EOF
#!/bin/bash
yum -y install tcpdump iptraf
hostname Si-NAT-10-3-1-100
EOF
}


resource "aws_instance" "singa_pri1" {
  provider = aws.singa
  ami           = var.singa-ami
  instance_type = "t2.micro"
  # associate_public_ip_address = "true"
  private_ip = "10.3.3.100"
  subnet_id = aws_subnet.singa["sn3"].id
  security_groups = [aws_security_group.singa.id]
  tags = {
    Name = "singa_pri1"
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
echo "<h1>singa AWS Private Instance 1</h1>" > /var/www/html/index.html
hostname Si-Private-10-3-3-100
EOF
}