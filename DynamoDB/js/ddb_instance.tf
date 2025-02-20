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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts
nvm install 16.18.0
npm install aws-sdk
EOF
}
