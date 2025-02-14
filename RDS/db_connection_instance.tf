
resource "aws_instance" "aws_con_instance" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  key_name = var.se_key
  tags = {
    Name = "aws_con_instance"
  }
  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install epel -y
wget https://dev.mysql.com/get/mysql80-community-release-el7-9.noarch.rpm
yum localinstall mysql80-community-release-el7-9.noarch.rpm -y
yum install mysql-community-server-8.0.40 --nogpgcheck -y
EOF
}
