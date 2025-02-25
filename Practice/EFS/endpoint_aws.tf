resource "aws_vpc_endpoint" "datasync_endpoint" {
  vpc_id             = aws_vpc.aws_vpc.id
  service_name       = "com.amazonaws.ap-northeast-2.datasync"  
  vpc_endpoint_type  = "Interface"                          
  subnet_ids = [aws_subnet.aws_subnet["aws1"].id]         
  security_group_ids = [aws_security_group.aws_securitygroup.id] 
  private_dns_enabled = true
  tags = {
    Name = "datasync-vpc-endpoint"
  }
}