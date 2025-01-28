resource "aws_security_group" "idc-singa" {
  provider = aws.singa
  name   = "idc-singa_pub"
  vpc_id = aws_vpc.idc-singa.id
  dynamic "ingress" {
    for_each = [
      { from_port = 22, to_port = 22, protocol = "tcp" },
      { from_port = 80, to_port = 80, protocol = "tcp" },
      { from_port = 443, to_port = 443, protocol = "tcp" },
      { from_port = 53, to_port = 53, protocol = "udp" },
      { from_port = 53, to_port = 53, protocol = "tcp" },
      { from_port = 4500, to_port = 4500, protocol = "udp" },
      { from_port = 3306, to_port = 3306, protocol = "tcp" },
      { from_port = -1, to_port = -1, protocol = "icmp" }
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}