resource "aws_vpc" "idc_vpc" {
  provider = aws.se
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "idc_vpc"
  }
}

resource "aws_subnet" "idc_subnet" {
  provider = aws.se
  for_each = {
    idc1 = {cidr_block="10.0.1.0/24",availability_zone="ap-northeast-2a"}
    idc2 = {cidr_block="10.0.2.0/24",availability_zone="ap-northeast-2b"}
    idc3 = {cidr_block="10.0.3.0/24",availability_zone="ap-northeast-2c"}
  }
  vpc_id     = aws_vpc.idc_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "idc_routetable" {
  provider = aws.se
  for_each = {
    ipub1 = {}
    # apri3 = {}
    # apri4 = {}
    # avpn5 = {}
    # avpn6 = {}
  }
  vpc_id = aws_vpc.idc_vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "idc_routetable_association" {
  provider = aws.se
    for_each = {
      idc1 = {route_table_id=aws_route_table.idc_routetable["ipub1"].id, subnet_id=aws_subnet.idc_subnet["idc1"].id}
      idc2 = {route_table_id=aws_route_table.idc_routetable["ipub1"].id, subnet_id=aws_subnet.idc_subnet["idc2"].id}
      idc3 = {route_table_id=aws_route_table.idc_routetable["ipub1"].id, subnet_id=aws_subnet.idc_subnet["idc3"].id}
    }
  route_table_id = each.value.route_table_id
  subnet_id = each.value.subnet_id
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = aws_vpc.idc_vpc.id
  vpc_id        = aws_vpc.aws_vpc.id
  auto_accept = true 
  tags = {
      Name = "vpc-peering"
  }
}

resource "aws_route" "idc_to_aws" {
  route_table_id            = aws_route_table.idc_routetable["ipub1"].id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_instance" "idc_instance_web1" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.1.30"
  subnet_id = aws_subnet.idc_subnet["idc1"].id
  key_name = var.se_key
  security_groups = [aws_security_group.idc_securitygroup.id]
  tags = {
    Name = "idc_instance_web1"
  }
  depends_on = [ aws_efs_mount_target.idc_efs_target ]
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
mount -t efs -o tls ${aws_efs_file_system.idc_efs.id}:/ /soldesk
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance idc_instance_web1</h1>" > /var/www/html/index.html
EOF
}


resource "aws_instance" "idc_instance_web2" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.1.31"
  subnet_id = aws_subnet.idc_subnet["idc1"].id
  key_name = var.se_key
  security_groups = [aws_security_group.idc_securitygroup.id]
  tags = {
    Name = "idc_instance_web2"
  }
  depends_on = [ aws_efs_mount_target.idc_efs_target ]
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
mount -t efs -o tls ${aws_efs_file_system.idc_efs.id}:/ /soldesk
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance idc_instance_web2</h1>" > /var/www/html/index.html
EOF
}


resource "aws_instance" "idc_instance_web3" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  associate_public_ip_address = "true"
  private_ip = "10.0.3.30"
  subnet_id = aws_subnet.idc_subnet["idc3"].id
  key_name = var.se_key
  security_groups = [aws_security_group.idc_securitygroup.id]
  tags = {
    Name = "idc_instance_web3"
  }
  depends_on = [ aws_efs_mount_target.idc_efs_target ]
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
mount -t efs -o tls ${aws_efs_file_system.idc_efs.id}:/ /soldesk
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Seoul AWS Public Instance idc_instance_web2</h1>" > /var/www/html/index.html
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