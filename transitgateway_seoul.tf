resource "aws_ec2_transit_gateway" "se_tgw" {
  provider = aws.se
  tags = {
    Name = "se_tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "se_tgw_vpcattach" {
  provider = aws.se
  subnet_ids = [
    aws_subnet.ase_subnet["asn5"].id,
    aws_subnet.ase_subnet["asn6"].id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = "se_tgw_vpcattach"
  }
}