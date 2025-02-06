resource "aws_instance" "ase_instance_web1" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  # associate_public_ip_address = "true"
  private_ip = "10.1.3.100"
  subnet_id = aws_subnet.ase_subnet["asn3"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_web1"
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
echo "<h1>Seoul AWS Private Instance 10.1.3.100</h1>" > /var/www/html/index.html
yum install -y git
wget -r -np -nH --cut-dirs=2 -A "*.sh,*.sh,*.txt,*.conf" -R "*" https://github.com/timangs/initial_configuration_terraform/tree/main/web_sample/
#/root/tree/main/web_sample에 받아짐
mv /root/initial_configuration_terraform/web_sample/* /var/www/html/
EOF
}

resource "aws_instance" "ase_instance_web2" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  # associate_public_ip_address = "true"
  private_ip = "10.1.4.100"
  subnet_id = aws_subnet.ase_subnet["asn4"].id
  security_groups = [aws_security_group.ase_securitygroup.id]
  tags = {
    Name = "ase_instance_web2"
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
echo "<h1>Seoul AWS Private Instance 10.1.4.100</h1>" > /var/www/html/index.html
EOF
}