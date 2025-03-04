resource "aws_instance" "aws_con_instance" {
  provider = aws.se
  ami           = var.se_ami2
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  key_name = var.se_key
  tags = {
    Name = "aws_con_instance"
  }
  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install epel -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EOF
}
