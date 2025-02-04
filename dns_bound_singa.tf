resource "aws_route53_resolver_endpoint" "asi_inbound" {
  provider = aws.si
  direction = "INBOUND"
  name      = "asi_inbound"
  security_group_ids = [aws_security_group.asi_securitygroup.id]
  ip_address {
    subnet_id = aws_subnet.asi_subnet["asn3"].id
    ip        = "10.3.3.250"
  }
  ip_address {
    subnet_id = aws_subnet.asi_subnet["asn4"].id
    ip        = "10.3.4.250"
  }
  tags = {
    Name = "asi_inbound"
  }
}

resource "aws_route53_resolver_endpoint" "asi_outbound" {
  provider = aws.si
  direction = "OUTBOUND"
  name      = "asi_outbound"
  security_group_ids = [aws_security_group.asi_securitygroup.id]
  ip_address {
    subnet_id = aws_subnet.asi_subnet["asn3"].id
    ip        = "10.3.3.251"
  }
  ip_address {
    subnet_id = aws_subnet.asi_subnet["asn4"].id
    ip        = "10.3.4.251"
  }
  tags = {
    Name = "asi_outbound"
  }
}

resource "aws_route53_resolver_rule" "asi_rule1" {
  provider = aws.si
  rule_type           = "FORWARD"
  domain_name         = "idcsinga.internal."
  name                = "asi_rule1"
  resolver_endpoint_id = aws_route53_resolver_endpoint.asi_outbound.id
  target_ip {
    ip   = "10.4.1.200"
    port = 53
  }
  tags = {
    Name = "asi_rule1"
  }
}

resource "aws_route53_resolver_rule" "asi_rule2" {
  provider = aws.si
  rule_type           = "FORWARD"
  domain_name         = "awsseoul.internal."
  name                = "asi_rule2"
  resolver_endpoint_id = aws_route53_resolver_endpoint.asi_outbound.id
  target_ip {
    ip   = "10.1.3.250"
    port = 53
  }
  target_ip {
    ip   = "10.1.4.250"
    port = 53
  }
  tags = {
    Name = "asi_rule2"
  }
}

resource "aws_route53_resolver_rule" "asi_rule3" {
  provider = aws.si
  rule_type           = "FORWARD"
  domain_name         = "idcseoul.internal."
  name                = "asi_rule3"
  resolver_endpoint_id = aws_route53_resolver_endpoint.asi_outbound.id
  target_ip {
    ip   = "10.2.1.200"
    port = 53
  }
  tags = {
    Name = "asi_rule3"
  }
}

resource "aws_route53_resolver_rule_association" "asi_rule1_association" {
  provider = aws.si
  name             = "asi_rule1_association"
  resolver_rule_id = aws_route53_resolver_rule.asi_rule1.id
  vpc_id           = aws_vpc.asi_vpc.id
}

resource "aws_route53_resolver_rule_association" "asi_rule2_association" {
  provider = aws.si
  name             = "asi_rule2_association"
  resolver_rule_id = aws_route53_resolver_rule.asi_rule2.id
  vpc_id           = aws_vpc.asi_vpc.id
}

resource "aws_route53_resolver_rule_association" "asi_rule3_association" {
  provider = aws.si
  name             = "asi_rule3_association"
  resolver_rule_id = aws_route53_resolver_rule.asi_rule3.id
  vpc_id           = aws_vpc.asi_vpc.id
}
######################################################################