resource "aws_ec2_transit_gateway" "seoul" {
  provider = aws.seoul
  tags = {
    Name = "seoul-tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "seoul" {
  provider = aws.seoul
  subnet_ids = [
    module.seoul.subnet1_id,
    module.seoul.subnet2_id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.seoul.id
  vpc_id = module.seoul.vpc_id
  tags = {
    Name = "seoul-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway" "singa" {
  provider = aws.singa
  tags = {
    Name = "singa-tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "singa" {
  provider = aws.singa
  subnet_ids = [module.singa.subnet1_id]
  transit_gateway_id = aws_ec2_transit_gateway.singa.id
  vpc_id = module.singa.vpc_id
  tags = {
    Name = "singa-tgw-attachment"
  }
}