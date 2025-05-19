resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peeringattach" {
  provider = aws.se
  peer_region             = "ap-southeast-1"
  transit_gateway_id      = aws_ec2_transit_gateway.se_tgw.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
  tags = {
    Name = "tgw_peeringattach"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peeringattach_accepter" {
  provider                       = aws.si
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach ]
  tags = {
    Name = "tgw_peeringattach_accepter"
  }
}


