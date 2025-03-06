data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "aws_con_instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "Instance-key"
  tags = {
    Name = "aws_con_instance"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install git -y
yum install python3 python3-pip -y

git clone https://github.com/timangs/log_application.git /home/ec2-user/log_application  # ec2-user 홈 디렉토리에 클론
cd /home/ec2-user/log_application

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
pip install gunicorn  # Gunicorn 설치
sudo chown -R ec2-user:ec2-user /home/ec2-user/log_application/.venv

nohup gunicorn --workers 3 --bind 0.0.0.0:8000 app:app > gunicorn.log 2>&1 &
EOF
}
