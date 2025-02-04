
resource "aws_route53_resolver_endpoint" "ase_inbound" {
  provider = aws.se
  direction = "INBOUND"
  name      = "ase_inbound"
  security_group_ids = [aws_security_group.ase_securitygroup.id]
  ip_address {
    subnet_id = aws_subnet.ase_subnet["asn5"].id
    ip        = "10.1.5.250"
  }
  ip_address {
    subnet_id = aws_subnet.ase_subnet["asn6"].id
    ip        = "10.1.6.250"
  }
  tags = {
    Name = "ase_inbound"
  }
}

resource "aws_route53_resolver_endpoint" "ase_outbound" {
  provider = aws.se
  direction = "OUTBOUND"
  name      = "ase_outbound"
  security_group_ids = [aws_security_group.ase_securitygroup.id]
  ip_address {
    subnet_id = aws_subnet.ase_subnet["asn5"].id
    ip        = "10.1.5.251"
  }
  ip_address {
    subnet_id = aws_subnet.ase_subnet["asn6"].id
    ip        = "10.1.6.251"
  }
  tags = {
    Name = "ase_outbound"
  }
}

resource "aws_route53_resolver_rule" "ase_rule1" {
  provider = aws.se
  rule_type           = "FORWARD"
  domain_name         = "idcsinga.internal"
  name                = "ase_rule1"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ase_outbound.id
  target_ip {
    ip   = "10.4.1.200"
    port = 53
  }
  tags = {
    Name = "ase_rule1"
  }
}

resource "aws_route53_resolver_rule" "ase_rule2" {
  provider = aws.se
  rule_type           = "FORWARD"
  domain_name         = "awssinga.internal"
  name                = "ase_rule2"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ase_outbound.id
  target_ip {
    ip   = "10.3.3.250"
    port = 53
  }
  target_ip {
    ip   = "10.3.4.250"
    port = 53
  }
  tags = {
    Name = "ase_rule2"
  }
}

resource "aws_route53_resolver_rule" "ase_rule3" {
  provider = aws.se
  rule_type           = "FORWARD"
  domain_name         = "idcseoul.internal"
  name                = "ase_rule3"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ase_outbound.id
  target_ip {
    ip   = "10.2.1.200"
    port = 53
  }
  tags = {
    Name = "ase_rule3"
  }
}

resource "aws_route53_resolver_rule_association" "ase_rule1_association" {
  provider = aws.se
  name             = "ase_rule1_association"
  resolver_rule_id = aws_route53_resolver_rule.ase_rule1.id
  vpc_id           = aws_vpc.ase_vpc.id
}

resource "aws_route53_resolver_rule_association" "ase_rule2_association" {
  provider = aws.se
  name             = "ase_rule2_association"
  resolver_rule_id = aws_route53_resolver_rule.ase_rule2.id
  vpc_id           = aws_vpc.ase_vpc.id
}

resource "aws_route53_resolver_rule_association" "ase_rule3_association" {
  provider = aws.se
  name             = "ase_rule3_association"
  resolver_rule_id = aws_route53_resolver_rule.ase_rule3.id
  vpc_id           = aws_vpc.ase_vpc.id
}
