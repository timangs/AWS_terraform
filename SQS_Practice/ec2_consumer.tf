resource "aws_instance" "aws_consumer_instance" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  key_name = var.se_key
  iam_instance_profile = "_ec2_admin"
  tags = {
    Name = "aws_consumer_instance"
  }
  user_data = <<EOD
#!/bin/bash
yum update -y
yum groupinstall -y "Development Tools"
yum install -y python3-pip
# worker.py을 만들어서 module 만해결
EOD
}
