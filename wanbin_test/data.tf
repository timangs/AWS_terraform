data "aws_availability_zones" "seoul" {
  provider = aws.seoul
  state = "available"
}

data "aws_availability_zones" "sp" {
  provider = aws.sp
  state    = "available"
}

data "aws_ami" "seoul" {
  provider = aws.seoul
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_ami" "sp" {
  provider = aws.sp
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# data "aws_ec2_transit_gateway_route_table" "sp" {
#   provider = aws.sp
#   filter {
#     name   = "default-association-route-table"
#     values = ["true"]
#   }
# }
