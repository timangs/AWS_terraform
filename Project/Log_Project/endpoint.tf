# S3 Gateway Endpoint
# ECR API Interface Endpoint
# ECR DKR Interface Endpoint

variable "aws_region" {
  description = "AWS Region for the endpoint"
  type        = string
  default     = "ap-northeast-2"
}

# S3 Gateway VPC Endpoint 
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3" 
  vpc_endpoint_type = "Gateway"    
  route_table_ids = [aws_route_table.log[0].id]

  tags = {
    Name = "${var.h}s3-gateway-endpoint"
  }
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api_interface" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api" 
  vpc_endpoint_type = "Interface"   
  subnet_ids = [
    aws_subnet.log[0].id,
    aws_subnet.log[1].id,
    aws_subnet.log[2].id,
    aws_subnet.log[3].id
  ]
  private_dns_enabled = true
  security_group_ids = [aws_security_group.kibana_lb_sg.id]
  tags = {
    Name = "${var.h}ecr-api-interface-endpoint"
  }
}

# ECR DKR Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr_interface" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.log[0].id,
    aws_subnet.log[1].id,
    aws_subnet.log[2].id,
    aws_subnet.log[3].id
  ]
  private_dns_enabled = true
  security_group_ids = [aws_security_group.kibana_lb_sg.id]
  tags = {
    Name = "${var.h}ecr-dkr-interface-endpoint"
  }
}