resource "aws_security_group" "idc_securitygroup" {
  provider = aws.se
  name     = "idc_securitygroup"
  vpc_id   = aws_vpc.idc_vpc.id
  dynamic "ingress" {
    for_each = [
      {from=53, to=53, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=53, to=53, protocol="udp", cidr=["0.0.0.0/0"]},
      {from=80, to=80, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=443, to=443, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=22, to=22, protocol="tcp", cidr=["0.0.0.0/0"]},
      {from=-1, to=-1, protocol="icmp", cidr=["0.0.0.0/0"]},
      {from=2049, to=2049, protocol="tcp", cidr=["0.0.0.0/0"]}
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
    Name = "ase_securitygroup"
  }
}