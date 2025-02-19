resource "aws_instance" "aws_con_instance" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  key_name = var.se_key
  iam_instance_profile = "_ec2_admin"
  tags = {
    Name = "aws_con_instance"
  }
  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install epel -y
wget https://dev.mysql.com/get/mysql80-community-release-el7-9.noarch.rpm
yum localinstall mysql80-community-release-el7-9.noarch.rpm -y
yum install mysql-community-server-8.0.40 --nogpgcheck -y
yum install -y httpd
# systemctl start httpd
# systemctl enable httpd
useradd soldesk
yum install -y php php-mysqlnd php-gd php-mbstring php-xml
# systemctl restart httpd
# for file in $(aws s3 ls s3://timangs-temp-files/ | awk '{print $4}'); do
#   aws s3 cp s3://timangs-temp-files/$file /var/www/html/; done
EOF
}

#ALTER USER 'root'@'localhost' IDENTIFIED BY 'Qwer!234';
