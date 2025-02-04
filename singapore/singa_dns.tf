resource "aws_route53_zone" "singa" {
  provider = aws.singa
  name = "awssinga.internal"
  vpc {vpc_id = aws_vpc.singa.id}  
}
resource "aws_route53_record" "singa_web1" {
  provider = aws.singa
  zone_id = aws_route53_zone.singa.zone_id
  name    = "web1.awssinga.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.singa_pri1.private_ip]
}

resource "aws_route53_resolver_endpoint" "inbound" {
  provider = aws.singa
  direction = "INBOUND"
  name      = "singa-ibep"
  security_group_ids = [aws_security_group.singa.id]
  ip_address {
    subnet_id = aws_subnet.singa["sn3"].id
    ip        = "10.3.3.250"
  }
  ip_address {
    subnet_id = aws_subnet.singa["sn4"].id
    ip        = "10.3.4.250"
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  provider = aws.singa
  direction = "OUTBOUND"
  name      = "singa-obep"
  security_group_ids = [aws_security_group.singa.id]
  ip_address {
    subnet_id = aws_subnet.singa["sn3"].id
    ip        = "10.3.3.251"
  }
  ip_address {
    subnet_id = aws_subnet.singa["sn4"].id
    ip        = "10.3.4.251"
  }
}

resource "aws_route53_resolver_rule" "outbound_rule" {
  provider = aws.singa
  domain_name = "idcsinga.internal"
  target_ip {
    ip = "10.4.1.200"  
  }
  rule_type = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id 
  name = "singa-outbound-rule"
}

resource "aws_route53_resolver_rule_association" "outbound_association" {
  provider = aws.singa
  resolver_rule_id = aws_route53_resolver_rule.outbound_rule.id
  vpc_id           = aws_vpc.singa.id 
}