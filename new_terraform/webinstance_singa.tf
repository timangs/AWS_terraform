
resource "aws_instance" "asi_instance_web1" {
  provider = aws.si
  ami           = var.si_ami
  instance_type = var.instance_type
  # associate_public_ip_address = "true"
  private_ip = "10.3.3.100"
  subnet_id = aws_subnet.ase_subnet["asn3"].id
  security_groups = [aws_security_group.asi_securitygroup.id]
  tags = {
    Name = "asi_instance_web1"
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
echo "<h1>Seoul AWS Private Instance 10.3.3.100</h1>" > /var/www/html/index.html
EOF
}