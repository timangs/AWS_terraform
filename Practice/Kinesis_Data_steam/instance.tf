resource "aws_instance" "producer" {
  ami           = data.aws_ami.amazon_linux_2.id
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
amazon-linux-extras enable python3.8
yum install -y aws-cli python38 pip
pip3.8 install boto3
EOF
}


resource "aws_instance" "consumer" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "Instance-key"
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_admin_profile.name 
  provisioner "file" {
    source      = "consumer.py"
    destination = "/home/ec2-user/consumer.py"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("../../seoul-key") 
    host     = self.public_ip
  }
  tags = {
    Name = "consumer"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras enable python3.8
yum install -y aws-cli python38 pip
pip3.8 install boto3
EOF
}
