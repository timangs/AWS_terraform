resource "aws_security_group" "asi_securitygroup" {
  provider = aws.si
  name     = "asi_securitygroup"
  vpc_id   = aws_vpc.asi_vpc.id
  dynamic "ingress" {
    for_each = [
      {from=53, to=53, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=53, to=53, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=80, to=80, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=443, to=443, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=22, to=22, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=-1, to=-1, protocol="icmp", cidr=["0.0.0.0/0"]},
      {from=4500, to=4500, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=3306, to=3306, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=179, to=179, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=500, to=500, protocol="udp", cidr=["0.0.0.0/0"]}
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
    Name = "asi_securitygroup"
  }
}