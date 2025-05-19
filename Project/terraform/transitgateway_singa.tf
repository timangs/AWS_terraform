resource "aws_ec2_transit_gateway" "si_tgw" {
  provider = aws.si
  tags = {
    Name = "si_tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "si_tgw_vpcattach" {
  provider = aws.si
  subnet_ids = [
    aws_subnet.asi_subnet["asn5"].id,
    aws_subnet.asi_subnet["asn6"].id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
  vpc_id = aws_vpc.asi_vpc.id
  tags = {
    Name = "si_tgw_vpcattach"
  }
}