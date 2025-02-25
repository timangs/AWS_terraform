resource "aws_vpc" "aws_vpc" {
  provider = aws.se
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "aws_vpc"
  }
}

resource "aws_subnet" "aws_subnet" {
  provider = aws.se
  for_each = {
    aws1 = {cidr_block="10.1.1.0/24",availability_zone="ap-northeast-2a"}
  }
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "aws_routetable" {
  provider = aws.se
  for_each = {
    apub1 = {}
  }
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name = each.key
  }
}


resource "aws_route_table_association" "aws_routetable_association" {
  provider = aws.se
    for_each = {
      aws1 = {route_table_id=aws_route_table.aws_routetable["apub1"].id, subnet_id=aws_subnet.aws_subnet["aws1"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}

resource "aws_route" "aws_to_idc" {
  route_table_id            = aws_route_table.aws_routetable["apub1"].id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_instance" "aws_instance_web1" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.1.1.30"
  subnet_id = aws_subnet.aws_subnet["aws1"].id
  key_name = var.se_key
  security_groups = [aws_security_group.aws_securitygroup.id]
  tags = {
    Name = "aws_instance_web1"
  }
  iam_instance_profile = aws_iam_instance_profile.temp_role.name
  depends_on = [ aws_efs_mount_target.aws_efs_target ]
  user_data = <<EOF
#!/bin/bash
# echo "toor" | passwd --stdin root
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# systemctl restart sshd
amazon-linux-extras install epel -y
yum install -y amazon-efs-utils
mkdir /soldesk
sleep 30
mount -t efs -o tls ${aws_efs_file_system.aws_efs.id}:/ /soldesk
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance aws_instance_web1</h1>" > /var/www/html/index.html
EOF
}


resource "aws_instance" "aws_instance_datasync1" {
  provider = aws.se
  ami           = var.se_datasync_ami
  instance_type = var.datasync_instance_type
  associate_public_ip_address = "true"
  private_ip = "10.1.1.100"
  subnet_id = aws_subnet.aws_subnet["aws1"].id
  key_name = var.se_key
  security_groups = [aws_security_group.aws_securitygroup.id]
  tags = {
    Name = "aws_instance_datasync1"
  }
  iam_instance_profile = aws_iam_instance_profile.datasync_role.name
  depends_on = [ aws_efs_mount_target.aws_efs_target ]
}