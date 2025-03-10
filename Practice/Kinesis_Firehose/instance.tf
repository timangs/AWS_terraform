resource "aws_instance" "producer" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "Instance-key"
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_admin_profile.name
  provisioner "file" {
    source      = "producer.py"
    destination = "/home/ec2-user/producer.py"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("../../seoul-key")
    host     = self.public_ip
  }
  tags = {
    Name = "producer"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y aws-cli python3 pip
pip3 install boto3
EOF
}