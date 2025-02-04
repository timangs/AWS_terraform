resource "aws_vpc" "seoul" {
  provider = aws.seoul
  for_each = {
    aws = {cidr="10.1.0.0/16"}
    idc = {cidr="10.2.0.0/16"}
  }
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = each.value.cidr
  tags = {
    Name = each.key
  }
}
resource "aws_vpc" "sp" {
  provider = aws.sp
  for_each = {
    aws = {cidr="10.3.0.0/16"}
    idc = {cidr="10.4.0.0/16"}
  }
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = each.value.cidr
  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "seoul" {
  for_each = {
    aws = {vpc=aws_vpc.seoul["aws"].id}
    idc = {vpc=aws_vpc.seoul["idc"].id}
  }
  provider = aws.seoul
  vpc_id = each.value.vpc
  tags = {
    Name = each.key
  }
}
resource "aws_internet_gateway" "sp" {
  for_each = {
    aws = {vpc=aws_vpc.sp["aws"].id}
    idc = {vpc=aws_vpc.sp["idc"].id}
  }
  provider = aws.sp
  vpc_id = each.value.vpc
  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "seoul" {
  provider = aws.seoul
  for_each = {
    aws_public_sn1 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.1.0/24",zone=data.aws_availability_zones.seoul.names[0]}
    aws_public_sn2 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.2.0/24",zone=data.aws_availability_zones.seoul.names[2]}
    aws_private_sn1 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.3.0/24",zone=data.aws_availability_zones.seoul.names[0]}
    aws_private_sn2 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.4.0/24",zone=data.aws_availability_zones.seoul.names[2]}
    aws_peris_sn1 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.5.0/24",zone=data.aws_availability_zones.seoul.names[0]}
    aws_peris_sn2 = {vpc_id=aws_vpc.seoul["aws"].id,cidr_block="10.1.6.0/24",zone=data.aws_availability_zones.seoul.names[2]}
    idc_sn1 = {vpc_id=aws_vpc.seoul["idc"].id,cidr_block="10.2.1.0/24",zone=data.aws_availability_zones.seoul.names[0]}
    idc_sn2 = {vpc_id=aws_vpc.seoul["idc"].id,cidr_block="10.2.2.0/24",zone=data.aws_availability_zones.seoul.names[2]}
  }
  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.zone
  tags = {
    Name = each.key
  }
}
resource "aws_subnet" "sp" {
  provider = aws.sp
  for_each = {
    aws_public_sn1 = {vpc_id=aws_vpc.sp["aws"].id,cidr_block="10.3.1.0/24",zone=data.aws_availability_zones.sp.names[0]}
    aws_private_sn1 = {vpc_id=aws_vpc.sp["aws"].id,cidr_block="10.3.3.0/24",zone=data.aws_availability_zones.sp.names[0]}
    aws_private_sn2 = {vpc_id=aws_vpc.sp["aws"].id,cidr_block="10.3.4.0/24",zone=data.aws_availability_zones.sp.names[2]}
    aws_peris_sn1 = {vpc_id=aws_vpc.sp["aws"].id,cidr_block="10.3.5.0/24",zone=data.aws_availability_zones.sp.names[0]}
    aws_peris_sn2 = {vpc_id=aws_vpc.sp["aws"].id,cidr_block="10.3.6.0/24",zone=data.aws_availability_zones.sp.names[2]}
    idc_sn1 = {vpc_id=aws_vpc.sp["idc"].id,cidr_block="10.4.1.0/24",zone=data.aws_availability_zones.sp.names[0]}
    idc_sn2 = {vpc_id=aws_vpc.sp["idc"].id,cidr_block="10.4.2.0/24",zone=data.aws_availability_zones.sp.names[2]}
  }
  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.zone
  tags = {
    Name = each.key
  }
}
resource "aws_route_table" "seoul" {
  provider = aws.seoul
  for_each = {
    aws1 = {vpc_id=aws_vpc.seoul["aws"].id}
    aws2 = {vpc_id=aws_vpc.seoul["aws"].id}
    aws3 = {vpc_id=aws_vpc.seoul["aws"].id}
    idc1 = {vpc_id=aws_vpc.seoul["idc"].id}
    idc2 = {vpc_id=aws_vpc.seoul["idc"].id}
  }
  vpc_id = each.value.vpc_id
  tags = {
    Name = each.key
  }
}
resource "aws_route" "seoul" {
  provider = aws.seoul
  for_each = {
    1 = {rt_id=aws_route_table.seoul["aws1"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.seoul["aws"].id}
    2 = {rt_id=aws_route_table.seoul["idc1"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.seoul["idc"].id}
    3 = {rt_id=aws_route_table.seoul["idc2"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.seoul["idc"].id}
    4 = {rt_id=aws_route_table.seoul["aws2"].id, cidr="0.0.0.0/0", ni_id=aws_instance.seoulNAT1.primary_network_interface_id}
    6 = {rt_id=aws_route_table.seoul["aws3"].id, cidr="0.0.0.0/0", ni_id=aws_instance.seoulNAT2.primary_network_interface_id}
    8 = {rt_id=aws_route_table.seoul["aws1"].id, cidr="10.0.0.0/8", tgw_id=aws_ec2_transit_gateway.seoul.id}
    9 = {rt_id=aws_route_table.seoul["idc1"].id, cidr="10.1.0.0/16", ni_id=aws_instance.seoul_idc_Instance3.primary_network_interface_id}
    10 = {rt_id=aws_route_table.seoul["idc1"].id, cidr="10.3.0.0/16", ni_id=aws_instance.seoul_idc_Instance3.primary_network_interface_id}
    11 = {rt_id=aws_route_table.seoul["idc1"].id, cidr="10.4.0.0/16", ni_id=aws_instance.seoul_idc_Instance3.primary_network_interface_id}
  }
  route_table_id = each.value.rt_id
  destination_cidr_block = each.value.cidr
  gateway_id = lookup(each.value, "gw_id", null)
  network_interface_id = lookup(each.value, "ni_id", null)
  transit_gateway_id = lookup(each.value, "tgw_id", null)
  depends_on = [aws_ec2_transit_gateway.seoul, aws_vpn_connection.seoul, aws_ec2_transit_gateway_peering_attachment.region_peering, aws_ec2_transit_gateway_peering_attachment_accepter.sp_seoul, aws_ec2_transit_gateway_vpc_attachment.seoul]
}

resource "aws_route_table_association" "seoul" {
  provider = aws.seoul
    for_each = {
      1 = {rt_id=aws_route_table.seoul["aws1"].id, subnet_id=aws_subnet.seoul["aws_public_sn1"].id}
      2 = {rt_id=aws_route_table.seoul["aws1"].id, subnet_id=aws_subnet.seoul["aws_public_sn2"].id}
      3 = {rt_id=aws_route_table.seoul["aws2"].id, subnet_id=aws_subnet.seoul["aws_private_sn1"].id}
      4 = {rt_id=aws_route_table.seoul["aws3"].id, subnet_id=aws_subnet.seoul["aws_private_sn2"].id}
      5 = {rt_id=aws_route_table.seoul["idc1"].id, subnet_id=aws_subnet.seoul["idc_sn1"].id}
      6 = {rt_id=aws_route_table.seoul["idc2"].id, subnet_id=aws_subnet.seoul["idc_sn2"].id}
    }
  route_table_id = each.value.rt_id
  subnet_id = each.value.subnet_id
}
resource "aws_route_table" "sp" {
  provider = aws.sp
  for_each = {
    aws1 = {vpc_id=aws_vpc.sp["aws"].id}
    aws2 = {vpc_id=aws_vpc.sp["aws"].id}
    idc1 = {vpc_id=aws_vpc.sp["idc"].id}
    idc2 = {vpc_id=aws_vpc.sp["idc"].id}
  }
  vpc_id = each.value.vpc_id
  tags = {
    Name = each.key
  }
}

resource "aws_route" "sp" {
  provider = aws.sp
  for_each = {
    1 = {rt_id=aws_route_table.sp["aws1"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.sp["aws"].id}
    2 = {rt_id=aws_route_table.sp["idc1"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.sp["idc"].id}
    3 = {rt_id=aws_route_table.sp["idc2"].id, cidr="0.0.0.0/0", gw_id=aws_internet_gateway.sp["idc"].id}
    4 = {rt_id=aws_route_table.sp["aws2"].id, cidr="0.0.0.0/0", ni_id=aws_instance.spNAT1.primary_network_interface_id}
    6 = {rt_id=aws_route_table.sp["aws1"].id, cidr="10.0.0.0/8", tgw_id=aws_ec2_transit_gateway.sp.id }
    7 = {rt_id=aws_route_table.sp["idc1"].id, cidr="10.1.0.0/16", ni_id=aws_instance.sp_idc_Instance3.primary_network_interface_id}
    8 = {rt_id=aws_route_table.sp["idc1"].id, cidr="10.2.0.0/16", ni_id=aws_instance.sp_idc_Instance3.primary_network_interface_id}
    9 = {rt_id=aws_route_table.sp["idc1"].id, cidr="10.3.0.0/16", ni_id=aws_instance.sp_idc_Instance3.primary_network_interface_id}
  }
  route_table_id = each.value.rt_id
  destination_cidr_block = each.value.cidr
  gateway_id = lookup(each.value, "gw_id", null)
  network_interface_id = lookup(each.value, "ni_id", null)
  transit_gateway_id = lookup(each.value, "tgw_id", null)
  depends_on = [aws_ec2_transit_gateway.sp, aws_vpn_connection.sp, aws_ec2_transit_gateway_peering_attachment.region_peering, aws_ec2_transit_gateway_peering_attachment_accepter.sp_seoul, aws_ec2_transit_gateway_vpc_attachment.sp]
}

resource "aws_route_table_association" "sp" {
  provider = aws.sp
  for_each = {
    1 = {rt_id=aws_route_table.sp["aws1"].id, subnet_id=aws_subnet.sp["aws_public_sn1"].id}
    2 = {rt_id=aws_route_table.sp["aws2"].id, subnet_id=aws_subnet.sp["aws_private_sn1"].id}
    3 = {rt_id=aws_route_table.sp["aws2"].id, subnet_id=aws_subnet.sp["aws_private_sn2"].id}
    4 = {rt_id=aws_route_table.sp["idc1"].id, subnet_id=aws_subnet.sp["idc_sn1"].id}
    5 = {rt_id=aws_route_table.sp["idc2"].id, subnet_id=aws_subnet.sp["idc_sn2"].id}
  }
  route_table_id = each.value.rt_id
  subnet_id = each.value.subnet_id
}
resource "aws_security_group" "seoul" {
  provider = aws.seoul
  for_each = {
    aws = {name="SEOUL-AWS-SG", vpc_id=aws_vpc.seoul["aws"].id}
    idc = {name="SEOUL-IDC-SG", vpc_id=aws_vpc.seoul["idc"].id}
  }

  name     = each.value.name
  vpc_id   = each.value.vpc_id

  dynamic "ingress" {
    for_each = [
      {from = 53, to=53, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from = 53, to=53, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=80, to=80, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=443, to=443, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=22, to=22, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=-1, to=-1, protocol="icmp", cidr=["10.0.0.0/8"]},
      {from=4500, to=4500, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=3306, to=3306, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=179, to=179, protocol="tcp", cidr=["10.0.0.0/8"]},
      {from=500, to=500, protocol="udp", cidr=["10.0.0.0/8"]}
    ]
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "seoul sg"
  }
}
resource "aws_instance" "seoulNAT1" {
  provider = aws.seoul
  ami           = var.seoul_nat_image_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.1.1.100"
  key_name = var.seoul_key_name
  subnet_id = aws_subnet.seoul["aws_public_sn1"].id
  security_groups = [aws_security_group.seoul["aws"].id]
  tags = {
    Name = "Seoul-NAT1"
  }
  depends_on = [ aws_internet_gateway.seoul["aws"]]
  user_data = <<EOF
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
hostname Seoul-AWS-NATInstance1
cat<<EOT>> /etc/resolv.conf
nameserver 10.1.3.250
nameserver 10.1.4.250
EOT
yum -y install tcpdump
EOF
}

resource "aws_instance" "seoulNAT2" {
  provider = aws.seoul
  ami           = var.seoul_nat_image_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  private_ip = "10.1.2.100"
  key_name = var.seoul_key_name
  source_dest_check = false
  subnet_id = aws_subnet.seoul["aws_public_sn2"].id
  security_groups = [aws_security_group.seoul["aws"].id]
  tags = {
    Name = "Seoul-NAT2"
  }
  depends_on = [ aws_internet_gateway.seoul["aws"]]
  user_data = <<EOF
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
hostname Seoul-AWS-NATInstance2
cat<<EOT>> /etc/resolv.conf
nameserver 10.1.3.250
nameserver 10.1.4.250
EOT
yum -y install tcpdump
EOF
}
resource "aws_instance" "seoulInstance1" {
  provider = aws.seoul
  ami           = data.aws_ami.seoul.id
  instance_type = var.instance_type
  private_ip = "10.1.3.100"
  key_name = var.seoul_key_name
  subnet_id = aws_subnet.seoul["aws_private_sn1"].id
  security_groups = [aws_security_group.seoul["aws"].id]
  source_dest_check = false
  tags = {
    Name = "Seoul-Instance1"
  }
  depends_on = [ aws_internet_gateway.seoul["aws"] ]
  user_data = <<EOF
#!/bin/bash
hostnamectl --static set-hostname Seoul-AWS-Web1
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd lynx
systemctl start httpd && systemctl enable httpd

cat<<EOT>> /etc/resolv.conf
nameserver 10.1.3.250
nameserver 10.1.4.250
EOT

mkdir /var/www/inc
curl -o /var/www/inc/dbinfo.inc php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/dbinfo.inc
curl -o /var/www/html/db.php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/db.php
rm -rf /var/www/html/index.html
echo "<h1>SeoulRegion - Web1</h1>" > /var/www/html/index.html
curl -o /opt/pingcheck.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter8/pingchecker.sh
chmod +x /opt/pingcheck.sh
cat <<EOT>> /etc/crontab
*/3 * * * * root /opt/pingcheck.sh
EOT
echo "1" > /var/www/html/HealthCheck.txt 
EOF
}
resource "aws_instance" "seoulInstance2" {
  provider = aws.seoul
  ami           = data.aws_ami.seoul.id
  instance_type = var.instance_type
  private_ip = "10.1.4.100"
  key_name = var.seoul_key_name
  subnet_id = aws_subnet.seoul["aws_private_sn2"].id
  security_groups = [aws_security_group.seoul["aws"].id]
  source_dest_check = false
  tags = {
    Name = "Seoul-Instance2"
  }
  depends_on = [ aws_internet_gateway.seoul["aws"]]
  user_data = <<EOF
#!/bin/bash
hostnamectl --static set-hostname Seoul-AWS-Web2
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd lynx
systemctl start httpd && systemctl enable httpd

cat<<EOT>> /etc/resolv.conf
nameserver 10.1.3.250
nameserver 10.1.4.250
EOT


mkdir /var/www/inc
curl -o /var/www/inc/dbinfo.inc php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/dbinfo.inc
curl -o /var/www/html/db.php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/db.php
rm -rf /var/www/html/index.html
echo "<h1>SeoulRegion - Web2</h1>" > /var/www/html/index.html
curl -o /opt/pingcheck.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter8/pingchecker.sh
chmod +x /opt/pingcheck.sh
cat <<EOT>> /etc/crontab
*/3 * * * * root /opt/pingcheck.sh
EOT
echo "1" > /var/www/html/HealthCheck.txt
EOF
}

#DNS
resource "aws_route53_zone" "seoul" {
  provider = aws.seoul
  name = "awsseoul.internal"
  vpc {
    vpc_id = aws_vpc.seoul["aws"].id
    vpc_region = "ap-northeast-2"
  }
  tags = {
    Name = "Seoul-AWS-DNS"
  }
}
resource "aws_route53_record" "seoul" {
  provider = aws.seoul
  for_each = {
    1 = {name = "web1.awsseoul.internal" , records=[aws_instance.seoulInstance1.private_ip]}
    2 = {name = "web2.awsseoul.internal" , records=[aws_instance.seoulInstance2.private_ip]}
  }
  zone_id = aws_route53_zone.seoul.zone_id
  name = each.value.name
  type = "A"
  ttl = 60
  records = each.value.records
}
resource "aws_route53_record" "alb" {
  provider = aws.seoul
  zone_id = aws_route53_zone.seoul.zone_id
  name    = "alb.awsseoul.internal"
  type    = "A"
  alias {
    name                   = aws_lb.seoul.dns_name
    zone_id                = aws_lb.seoul.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_resolver_endpoint" "seoul_aws_inbound" {
  provider = aws.seoul
  direction = "INBOUND"
  name      = "AWS Inbound Endpoint"
  security_group_ids = [aws_security_group.seoul["aws"].id]

  ip_address {
    subnet_id = aws_subnet.seoul["aws_private_sn1"].id
    ip        = "10.1.3.250"
  }

  ip_address {
    subnet_id = aws_subnet.seoul["aws_private_sn2"].id
    ip        = "10.1.4.250"
  }

  tags = {
    Name = "AWSseoulInboundEndpoint"
  }
}

resource "aws_route53_resolver_endpoint" "seoul_aws_outbound" {
  provider = aws.seoul
  direction = "OUTBOUND"
  name      = "AWS Outbound Endpoint"
  security_group_ids = [aws_security_group.seoul["aws"].id]

  ip_address {
    subnet_id = aws_subnet.seoul["aws_private_sn1"].id
    ip        = "10.1.3.251"
  }

  ip_address {
    subnet_id = aws_subnet.seoul["aws_private_sn2"].id
    ip        = "10.1.4.251"
  }

  tags = {
    Name = "AWSseoulOutboundEndpoint"
  }
}

resource "aws_route53_resolver_rule" "seoul_rule1" {
  provider = aws.seoul
  rule_type           = "FORWARD"
  domain_name         = "idcseoul.internal"
  name                = "IDC Seoul Rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.seoul_aws_outbound.id

  target_ip {
    ip   = aws_instance.seoul_idc_Instance2.private_ip
    port = 53
  }

  tags = {
    Name = "IDC Seoul Rule"
  }
}
resource "aws_route53_resolver_rule_association" "seoul_rule_ass1" {
  provider = aws.seoul
  name             = "RuleAssociation1"
  resolver_rule_id = aws_route53_resolver_rule.seoul_rule1.id
  vpc_id           = aws_vpc.seoul["aws"].id
}
resource "aws_route53_resolver_rule" "seoul_rule2" {
  provider = aws.seoul
  rule_type           = "FORWARD"
  domain_name         = "awssp.internal"
  name                = "aws sp rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.seoul_aws_outbound.id

  target_ip {
    ip   = "10.3.3.250"
    port = 53
  }

  target_ip {
    ip   = "10.3.4.250"
    port = 53
  }

  tags = {
    Name = "aws seoul rule"
  }
}
resource "aws_route53_resolver_rule_association" "seoul_rule_ass2" {
  provider = aws.seoul
  name             = "RuleAssociation2"
  resolver_rule_id = aws_route53_resolver_rule.seoul_rule2.id
  vpc_id           = aws_vpc.seoul["aws"].id
}
resource "aws_route53_resolver_rule" "seoul_rule3" {
  provider = aws.seoul
  rule_type           = "FORWARD"
  domain_name         = "idcsp.internal"
  name                = "idc sp rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.seoul_aws_outbound.id

  target_ip {
    ip   = aws_instance.sp_idc_Instance2.private_ip
    port = 53
  }

  tags = {
    Name = "idc seoul rule"
  }
}
resource "aws_route53_resolver_rule_association" "seoul_rule_ass3" {
  provider = aws.seoul
  name             = "RuleAssociation3"
  resolver_rule_id = aws_route53_resolver_rule.seoul_rule3.id
  vpc_id           = aws_vpc.seoul["aws"].id
}

#ALB
resource "aws_lb" "seoul" {
  provider = aws.seoul
  name               = "VPC1-Seoul-AWS-ALB"
  internal           = false
  security_groups    = [aws_security_group.seoul["aws"].id]
  subnets            = [aws_subnet.seoul["aws_public_sn1"].id, aws_subnet.seoul["aws_public_sn2"].id]
  load_balancer_type = "application"

  tags = {
    Name = "Seoul-AWS-ALB"
  }
}

resource "aws_lb_target_group" "seoul_albtg1" {
  provider = aws.seoul
  name                          = "ALBTG"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.seoul["aws"].id
  health_check {
    path                = "/HealthCheck.txt"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "VPC1-Seoul-AWS-ALBTG"
  }
}
resource "aws_lb_target_group_attachment" "seoul" {
  provider = aws.seoul
  for_each = {
    1 = {arn=aws_lb_target_group.seoul_albtg1.arn, target_id=aws_instance.seoulInstance1.id}
    2 = {arn=aws_lb_target_group.seoul_albtg1.arn, target_id=aws_instance.seoulInstance2.id}
  }
  target_group_arn = each.value.arn
  target_id        = each.value.target_id
  port             = 80
}

resource "aws_lb_listener" "seoul" {
  provider = aws.seoul
  load_balancer_arn = aws_lb.seoul.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.seoul_albtg1.arn
  }
}

resource "aws_instance" "seoul_idc_Instance1" {
  provider = aws.seoul
  ami           = data.aws_ami.seoul.id
  instance_type = var.instance_type
  private_ip = "10.2.1.100"
  key_name = var.seoul_key_name
  subnet_id = aws_subnet.seoul["idc_sn1"].id
  security_groups = [aws_security_group.seoul["idc"].id]
  source_dest_check = false
  tags = {
    Name = "Seoul-IDC-DB"
  }
  depends_on = [ aws_internet_gateway.seoul["idc"] ]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done

hostnamectl --static set-hostname Seoul-IDC-DB
cat<<EOT> /etc/resolv.conf
nameserver 10.2.1.200
EOT

yum install -y mariadb-server mariadb lynx
systemctl start mariadb && systemctl enable mariadb
echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
mysql -uroot -pqwe123 -e "CREATE DATABASE sample; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
mysql -uroot -pqwe123 -e "USE sample;CREATE TABLE EMPLOYEES (ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,NAME VARCHAR(45),ADDRESS VARCHAR(90));"
cat <<EOT> /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0           
log-bin=mysql-bin
server-id=1
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
EOT
systemctl restart mariadb
cat <<EOT> /home/ec2-user/list.txt
10.1.3.100
web1.awsseoul.internal
10.1.4.100
web2.awsseoul.internal
10.2.1.100
db.idcseoul.internal
10.2.1.200
dns.idcseoul.internal
10.3.3.100
web1.awssp.internal
10.4.1.100
db.idcsp.internal
10.4.1.200
dns.idcsp.internal
EOT
curl -o /home/ec2-user/pingall.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter6/pingall.sh --silent
chmod +x /home/ec2-user/pingall.sh
EOF
}

resource "aws_instance" "seoul_idc_Instance2" {
  provider = aws.seoul
  ami           = data.aws_ami.seoul.id
  instance_type = var.instance_type
  private_ip = "10.2.1.200"
  key_name = var.seoul_key_name
  associate_public_ip_address = true
  source_dest_check = false
  subnet_id = aws_subnet.seoul["idc_sn1"].id
  security_groups = [aws_security_group.seoul["idc"].id]
  tags = {
    Name = "Seoul-IDC-DNS"
  }
  depends_on = [ aws_internet_gateway.seoul["idc"] ]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done

cat<<EOT> /etc/resolv.conf
nameserver 10.2.1.200
EOT

hostnamectl --static set-hostname Seoul-IDC-DNS
sed -i "s/^127.0.0.1   localhost/127.0.0.1 localhost idc-seoul-dns/g" /etc/hosts
# Update and install necessary packages

yum clean all
rm -rf /var/cache/yum
yum update -y
yum install -y bind bind-utils glibc-langpack-ko

cat <<EOT > /etc/named.conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";        
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
        recursion yes;
        dnssec-enable no;
        dnssec-validation no;
        bindkeys-file "/etc/named.root.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};

cat <<EOT >> /etc/named.rfc1912.zones
zone "idcseoul.internal" {
    type master;
    file "/var/named/idcseoul.internal.zone";
};

zone "awsseoul.internal" {
    type forward;
    forwarders { 10.1.1.250; 10.1.2.250; };
};

zone "awssp.internal" {
    type forward;
    forwarders { 10.3.1.250; };
};

zone "idcsp.internal" {
    type forward;
    forwarders { 10.4.1.200; };
};
EOT

cat <<EOT > /var/named/idcseoul.internal.zone
\$TTL 86400
@   IN  SOA     ns.idcseoul.internal. admin.idcseoul.internal. (
        2025010801 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL
@       IN  NS      ns.idcseoul.internal.
ns      IN  A       10.2.1.200
dns     IN  A       10.2.1.200
db      IN  A       10.2.1.100
EOT

chown root:named /etc/named.conf /var/named/idcseoul.internal.zone
chmod 640 /etc/named.conf
chmod 640 /var/named/idcseoul.internal.zone

systemctl enable named
systemctl start named
EOF
}

resource "aws_network_interface" "seoul" {
  provider = aws.seoul
  subnet_id = aws_subnet.seoul["idc_sn2"].id
  private_ips = ["10.2.2.100"]
  security_groups = [aws_security_group.seoul["idc"].id]
  source_dest_check = false

  tags = {
    Name = "Seoul-IDC-VPN-ENI"
  }
}
resource "aws_eip" "seoul" {
provider = aws.seoul
network_interface = aws_network_interface.seoul.id
}
resource "aws_instance" "seoul_idc_Instance3" {
  provider = aws.seoul
  ami           = data.aws_ami.seoul.id
  instance_type = var.instance_type
  key_name = var.seoul_key_name
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.seoul.id
  }
  depends_on = [ aws_internet_gateway.seoul["idc"] ]
  tags = {
    Name = "Seoul-IDC-VPN"
  }
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done

cat<<EOT> /etc/resolv.conf
nameserver 10.2.1.200
EOT

hostnamectl --static set-hostname Seoul-IDC-VPN
yum -y install tcpdump openswan

word1="${aws_eip.seoul.public_ip}"
word2="${aws_vpn_connection.seoul.tunnel1_address}"
word3="${aws_vpn_connection.seoul.tunnel2_address}"

cat<<EOT>> /etc/resolv.conf
nameserver 10.2.1.200
EOT

cat <<EOT>> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.ip_vti0.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
EOT
sysctl -p /etc/sysctl.conf

cat <<EOT> /etc/ipsec.d/aws.conf
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word2"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer

conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word3"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=true
EOT
cat <<EOT> /etc/ipsec.d/aws.secrets
$word1 $word2 $word3 : PSK "cloudneta"
EOT

systemctl start ipsec
systemctl enable ipsec

EOF
}

resource "aws_security_group" "sp" {
  for_each = {
    aws = {name="SP-AWS-SG", vpc_id=aws_vpc.sp["aws"].id}
    idc = {name="SP-IDC-SG", vpc_id=aws_vpc.sp["idc"].id}
  }

  provider = aws.sp
  name     = each.value.name
  vpc_id   = each.value.vpc_id

  dynamic "ingress" {
    for_each = [
      {from = 53, to=53, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from = 53, to=53, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=80, to=80, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=443, to=443, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=22, to=22, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=-1, to=-1, protocol="icmp", cidr=["10.0.0.0/8"]},
      {from=4500, to=4500, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=3306, to=3306, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=179, to=179, protocol="tcp", cidr=["10.0.0.0/8"]},
      {from=500, to=500, protocol="udp", cidr=["10.0.0.0/8"]}
    ]
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sp sg"
  }
}
resource "aws_instance" "spNAT1" {
  provider = aws.sp
  ami           = var.sp_nat_image_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  private_ip = "10.3.1.100"
  key_name = var.sp_key_name
  subnet_id = aws_subnet.sp["aws_public_sn1"].id
  security_groups = [aws_security_group.sp["aws"].id]
  tags = {
    Name = "SP-NAT1"
  }
  depends_on = [ aws_internet_gateway.sp["aws"]]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
hostname Seoul-AWS-NATInstance1
cat<<EOT>> /etc/resolv.conf
nameserver 10.3.3.250
nameserver 10.4.4.250
EOT
yum -y install tcpdump
EOF
}

resource "aws_instance" "spInstance1" {
  provider = aws.sp
  ami           = data.aws_ami.sp.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  private_ip = "10.3.3.100"
  key_name = var.sp_key_name
  subnet_id = aws_subnet.sp["aws_private_sn1"].id
  security_groups = [aws_security_group.sp["aws"].id]
  source_dest_check = false
  depends_on = [ aws_internet_gateway.sp["aws"]]
  tags = {
    Name = "SP-Instance1"
  }
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done

hostnamectl --static set-hostname SP-AWS-Web1
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd lynx
systemctl start httpd && systemctl enable httpd

cat<<EOT>> /etc/resolv.conf
nameserver 10.3.3.250
nameserver 10.4.4.250
EOT

mkdir /var/www/inc
curl -o /var/www/inc/dbinfo.inc php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/dbinfo.inc
curl -o /var/www/html/db.php https://raw.githubusercontent.com/NoJamBean/Result1/refs/heads/main/db.php
rm -rf /var/www/html/index.html
echo "<h1>SPRegion - Web1</h1>" > /var/www/html/index.html
curl -o /opt/pingcheck.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter8/pingchecker.sh
chmod +x /opt/pingcheck.sh
cat <<EOT>> /etc/crontab
*/3 * * * * root /opt/pingcheck.sh
EOT
echo "1" > /var/www/html/HealthCheck.txt
EOF
}

#DNS
resource "aws_route53_zone" "sp" {
  provider = aws.sp
  name = "awssp.internal"
  vpc {
    vpc_id = aws_vpc.sp["aws"].id
    vpc_region = "ap-southeast-1"
  }
  tags = {
    Name = "SP-AWS-DNS"
  }
}

resource "aws_route53_record" "sp" {
  provider = aws.sp
  zone_id = aws_route53_zone.sp.zone_id
  name = "web1.awssp.internal"
  type = "A"
  ttl = 60
  records = [aws_instance.spInstance1.private_ip]
}

resource "aws_route53_resolver_endpoint" "sp_aws_inbound" {
  provider = aws.sp
  direction = "INBOUND"
  name      = "AWS Inbound Endpoint"
  security_group_ids = [aws_security_group.sp["aws"].id]

  ip_address {
    subnet_id = aws_subnet.sp["aws_private_sn1"].id
    ip        = "10.3.3.250"
  }

  ip_address {
    subnet_id = aws_subnet.sp["aws_private_sn2"].id
    ip        = "10.3.4.250"
  }

  tags = {
    Name = "AWSspInboundEndpoint"
  }
}

resource "aws_route53_resolver_endpoint" "sp_aws_outbound" {
  provider = aws.sp
  direction = "OUTBOUND"
  name      = "AWS Outbound Endpoint"
  security_group_ids = [aws_security_group.sp["aws"].id]

  ip_address {
    subnet_id = aws_subnet.sp["aws_private_sn1"].id
    ip        = "10.3.3.251"
  }

  ip_address {
    subnet_id = aws_subnet.sp["aws_private_sn2"].id
    ip        = "10.3.4.251"
  }

  tags = {
    Name = "AWSspOutboundEndpoint"
  }
}

resource "aws_route53_resolver_rule" "sp_rule1" {
  provider = aws.sp
  rule_type           = "FORWARD"
  domain_name         = "idcsp.internal"
  name                = "idc sp rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.sp_aws_outbound.id

  target_ip {
    ip   = aws_instance.sp_idc_Instance2.private_ip
    port = 53
  }

  tags = {
    Name = "idc sp rule"
  }
}

resource "aws_route53_resolver_rule_association" "sp_rule_ass1" {
  provider = aws.sp
  name             = "RuleAssociation1"
  resolver_rule_id = aws_route53_resolver_rule.sp_rule1.id
  vpc_id           = aws_vpc.sp["aws"].id
}

resource "aws_route53_resolver_rule" "sp_rule2" {
  provider = aws.sp
  rule_type           = "FORWARD"
  domain_name         = "awsseoul.internal"
  name                = "aws sp rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.sp_aws_outbound.id

  target_ip {
    ip   = "10.1.3.250"
    port = 53
  }

  target_ip {
    ip   = "10.1.4.250"
    port = 53
  }

  tags = {
    Name = "aws sp rule"
  }
}

resource "aws_route53_resolver_rule_association" "sp_rule_ass2" {
  provider = aws.sp
  name             = "RuleAssociation2"
  resolver_rule_id = aws_route53_resolver_rule.sp_rule2.id
  vpc_id           = aws_vpc.sp["aws"].id
}

resource "aws_route53_resolver_rule" "sp_rule3" {
  provider = aws.sp
  rule_type           = "FORWARD"
  domain_name         = "idcseoul.internal"
  name                = "aws sp rule"
  resolver_endpoint_id = aws_route53_resolver_endpoint.sp_aws_outbound.id

  target_ip {
    ip   = aws_instance.seoul_idc_Instance2.private_ip
    port = 53
  }

  tags = {
    Name = "aws sp rule"
  }
}

resource "aws_route53_resolver_rule_association" "sp_rule_ass3" {
  provider = aws.sp
  name             = "RuleAssociation3"
  resolver_rule_id = aws_route53_resolver_rule.sp_rule3.id
  vpc_id           = aws_vpc.sp["aws"].id
}

resource "aws_instance" "sp_idc_Instance1" {
  provider      = aws.sp
  ami           = data.aws_ami.sp.id
  instance_type = var.instance_type
  private_ip    = "10.4.1.100"
  key_name      = var.sp_key_name
  subnet_id     = aws_subnet.sp["idc_sn1"].id
  security_groups = [aws_security_group.sp["idc"].id]
  tags = {
    Name = "SP-IDC-DB"
  }
  depends_on = [ aws_internet_gateway.sp["idc"] ]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done
cat<<EOT> /etc/resolv.conf
nameserver 10.4.1.200
EOT
hostnamectl --static set-hostname SP-IDC-DB
yum install -y mariadb-server mariadb lynx
systemctl start mariadb && systemctl enable mariadb
echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
mysql -uroot -pqwe123 -e "CREATE DATABASE sample; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
mysql -uroot -pqwe123 -e "USE sample;CREATE TABLE EMPLOYEES (ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,NAME VARCHAR(45),ADDRESS VARCHAR(90));"
cat <<EOT> /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0           
log-bin=mysql-bin
server-id=1
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
EOT
systemctl restart mariadb
cat <<EOT> /home/ec2-user/list.txt
10.1.3.100
web1.awsseoul.internal
10.1.4.100
web2.awsseoul.internal
10.2.1.100
db.idcseoul.internal
10.2.1.200
dns.idcseoul.internal
10.3.3.100
web1.awssp.internal
10.4.1.100
db.idcsp.internal
10.4.1.200
dns.idcsp.internal
EOT
curl -o /home/ec2-user/pingall.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter6/pingall.sh --silent
chmod +x /home/ec2-user/pingall.sh
EOF
}

resource "aws_instance" "sp_idc_Instance2" {
  provider      = aws.sp
  ami           = data.aws_ami.sp.id
  instance_type = var.instance_type
  private_ip    = "10.4.1.200"
  key_name      = var.sp_key_name
  subnet_id     = aws_subnet.sp["idc_sn1"].id
  security_groups = [aws_security_group.sp["idc"].id]
  source_dest_check = false
  tags = {
    Name = "SP-IDC-DNS"
  }
  depends_on = [ aws_internet_gateway.sp["idc"] ]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done
cat<<EOT> /etc/resolv.conf
nameserver 10.4.1.200
EOT
hostnamectl --static set-hostname SP-IDC-DNS
sed -i "s/^127.0.0.1   localhost/127.0.0.1 localhost idc-sp-dns/g" /etc/hosts
# Update and install necessary packages
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done
yum clean all
rm -rf /var/cache/yum
yum update -y
yum install -y bind bind-utils glibc-langpack-ko

cat <<EOT > /etc/named.conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";        
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
        recursion yes;
        dnssec-enable no;
        dnssec-validation no;
        bindkeys-file "/etc/named.root.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};
cat <<EOT >> /etc/named.rfc1912.zones
zone "idcsp.internal" {
    type master;
    file "/var/named/idcsp.internal.zone";
};

zone "awsseoul.internal" {
    type forward;
    forwarders { 10.1.1.250; 10.1.2.250; };
};

zone "awssp.internal" {
    type forward;
    forwarders { 10.3.1.250; };
};

zone "idcseoul.internal" {
    type forward;
    forwarders { 10.2.1.200; };
};
EOT

cat <<EOT > /var/named/idcsp.internal.zone
\$TTL 86400
@   IN  SOA     ns.idcsp.internal. admin.idcsp.internal. (
        2025010801 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL
@       IN  NS      ns.idcsp.internal.
ns      IN  A       10.4.1.200
dns     IN  A       10.4.1.200
db      IN  A       10.4.1.100
EOT

chown root:named /etc/named.conf /var/named/idcsp.internal.zone
chmod 640 /etc/named.conf
chmod 640 /var/named/idcsp.internal.zone

systemctl enable named
systemctl start named
EOF
}

resource "aws_network_interface" "sp" {
  provider = aws.sp
  subnet_id = aws_subnet.sp["idc_sn2"].id
  private_ips = ["10.4.2.100"]
  security_groups = [aws_security_group.sp["idc"].id]
  source_dest_check = false

  tags = {
    Name = "SP-IDC-VPN-ENI"
  }
}
resource "aws_eip" "sp" {
provider = aws.sp
network_interface = aws_network_interface.sp.id
}
resource "aws_instance" "sp_idc_Instance3" {
  provider      = aws.sp
  ami           = data.aws_ami.sp.id
  instance_type = var.instance_type
  key_name      = var.sp_key_name
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.sp.id
  }
  tags = {
    Name = "SP-IDC-VPN"
  }
  depends_on = [ aws_internet_gateway.sp["idc"] ]
  user_data = <<EOF
#!/bin/bash
while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for network..."
    sleep 3
done
cat<<EOT> /etc/resolv.conf
nameserver 10.4.1.200
EOT
word1="${aws_eip.sp.public_ip}"
word2="${aws_vpn_connection.sp.tunnel1_address}"
word3="${aws_vpn_connection.sp.tunnel2_address}"

hostnamectl --static set-hostname SP-IDC-VPN
yum -y install tcpdump openswan

cat <<EOT>> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.ip_vti0.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
EOT
sysctl -p /etc/sysctl.conf

cat <<EOT> /etc/ipsec.d/aws.conf
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word2"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.4.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer

conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word3"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.4.0.0/16
  rightsubnet=10.0.0.0/8
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
  overlapip=true
EOT
cat <<EOT> /etc/ipsec.d/aws.secrets
$word1 $word2 $word3 : PSK "cloudneta"
EOT

systemctl start ipsec
systemctl enable ipsec
EOF
}

#Transit
resource "aws_ec2_transit_gateway_peering_attachment" "region_peering" {
  provider                 = aws.seoul
  peer_region              = "ap-southeast-1"
  peer_transit_gateway_id  = aws_ec2_transit_gateway.sp.id
  transit_gateway_id       = aws_ec2_transit_gateway.seoul.id
  tags                     = {Name = "TGW Peering"}

  depends_on = [aws_ec2_transit_gateway.seoul, aws_ec2_transit_gateway.sp]
}
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "sp_seoul" {
  provider = aws.sp
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.region_peering.id
  tags                          = {Name = "peering_sppore_seoul"}

  depends_on = [aws_ec2_transit_gateway_peering_attachment.region_peering]
}

resource "aws_ec2_transit_gateway" "seoul" {
  provider = aws.seoul
  tags = {
    Name = "Seoul TGW"
  }
  depends_on = [aws_customer_gateway.seoul]
}

resource "aws_ec2_transit_gateway" "sp" {
  provider = aws.sp
  tags = {
    Name = "SP TGW"
  }
  depends_on = [aws_customer_gateway.sp]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "seoul" {
  provider            = aws.seoul
  subnet_ids          = [aws_subnet.seoul["aws_peris_sn1"].id, aws_subnet.seoul["aws_peris_sn2"].id]
  transit_gateway_id  = aws_ec2_transit_gateway.seoul.id
  vpc_id              = aws_vpc.seoul["aws"].id

  depends_on = [aws_ec2_transit_gateway.seoul]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "sp" {
  provider            = aws.sp
  subnet_ids          = [aws_subnet.sp["aws_peris_sn1"].id, aws_subnet.sp["aws_peris_sn2"].id]
  transit_gateway_id  = aws_ec2_transit_gateway.sp.id
  vpc_id              = aws_vpc.sp["aws"].id

  depends_on = [aws_ec2_transit_gateway.sp]
}


resource "aws_customer_gateway" "seoul" {
  provider   = aws.seoul
  bgp_asn    = 65000
  ip_address = aws_eip.seoul.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "Seoul-Customer-Gateway"
  }
}

resource "aws_customer_gateway" "sp" {
  provider   = aws.sp
  bgp_asn    = 65002
  ip_address = aws_eip.sp.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "SP-Customer-Gateway"
  }
}

resource "aws_vpn_connection" "seoul" {
  provider             = aws.seoul
  customer_gateway_id  = aws_customer_gateway.seoul.id
  transit_gateway_id   = aws_ec2_transit_gateway.seoul.id
  type                 = "ipsec.1"
  static_routes_only   = true
  tunnel1_preshared_key = "cloudneta"
  tunnel2_preshared_key = "cloudneta"

  depends_on = [aws_customer_gateway.seoul, aws_ec2_transit_gateway.seoul]
}

resource "aws_vpn_connection" "sp" {
  provider             = aws.sp
  customer_gateway_id  = aws_customer_gateway.sp.id
  transit_gateway_id   = aws_ec2_transit_gateway.sp.id
  type                 = "ipsec.1"
  static_routes_only   = true
  tunnel1_preshared_key = "cloudneta"
  tunnel2_preshared_key = "cloudneta"

  depends_on = [aws_customer_gateway.sp, aws_ec2_transit_gateway.sp]
}


resource "aws_ec2_transit_gateway_route" "seoul" {
  provider = aws.seoul
  for_each = {
    1 = {cidr="10.2.0.0/16", tgwa_id=aws_vpn_connection.seoul.transit_gateway_attachment_id}
    2 = {cidr="10.3.0.0/16", tgwa_id=aws_ec2_transit_gateway_peering_attachment.region_peering.id}
    3 = {cidr="10.4.0.0/16", tgwa_id=aws_ec2_transit_gateway_peering_attachment.region_peering.id}
  }
  destination_cidr_block = each.value.cidr
  transit_gateway_attachment_id = each.value.tgwa_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.seoul.association_default_route_table_id
   depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.sp_seoul, aws_vpn_connection.seoul, aws_ec2_transit_gateway_vpc_attachment.seoul, aws_ec2_transit_gateway_vpc_attachment.sp]
}

resource "aws_ec2_transit_gateway_route" "sp" {
  provider = aws.sp
  for_each = {
    1 = {cidr="10.1.0.0/16", tgwa_id=aws_ec2_transit_gateway_peering_attachment.region_peering.id}
    2 = {cidr="10.2.0.0/16", tgwa_id=aws_ec2_transit_gateway_peering_attachment.region_peering.id}
    3 = {cidr="10.4.0.0/16", tgwa_id=aws_vpn_connection.sp.transit_gateway_attachment_id}
  }
  destination_cidr_block = each.value.cidr
  transit_gateway_attachment_id = each.value.tgwa_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.sp.association_default_route_table_id
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.sp_seoul, aws_vpn_connection.sp, aws_ec2_transit_gateway_vpc_attachment.sp, aws_ec2_transit_gateway_vpc_attachment.seoul]
}

  # GlobalAccelerator:
  #     Type: AWS::GlobalAccelerator::Accelerator
  #     Properties:
  #       Name: !Sub '${AWS::StackName}'
  #       Enabled: true
  #       IpAddressType: IPV4

  # GAListener:`
  #   Type: AWS::GlobalAccelerator::Listener
  #   Properties:
  #     AcceleratorArn: !Ref GlobalAccelerator
  #     Protocol: TCP
  #     PortRanges:
  #       - FromPort: 80
  #         ToPort: 80

  # GAEndpointGroup:
  #   Type: AWS::GlobalAccelerator::EndpointGroup
  #   DependsOn: ALB
  #   Properties:
  #     ListenerArn: !Ref GAListener
  #     EndpointGroupRegion: !Ref AWS::Region
  #     HealthCheckProtocol: HTTP
  #     HealthCheckPath: '/HealthCheck.txt'
  #     HealthCheckIntervalSeconds: 10
  #     ThresholdCount: 5
  #     EndpointConfigurations:
  #       - EndpointId: !Ref ALB

