resource "aws_instance" "producer" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "Instance-key"
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_admin_profile.name
  tags = {
    Name = "producer"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras enable python3.8
yum install -y aws-cli python38 pip
pip3.8 install boto3
EOF
}