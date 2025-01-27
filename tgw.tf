resource "aws_ec2_transit_gateway" "seoul" {
  provider = aws.seoul
  tags = {
    Name = "seoul-tgw"
  }
}
resource "aws_ec2_transit_gateway" "singa" {
  provider = aws.singa
  tags = {
    Name = "singa-tgw"
  }
}
