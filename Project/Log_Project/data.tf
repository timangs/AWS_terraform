data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_internet_gateway" "existing_igw" {
  count = var.use_existing_igw ? 1 : 0
  filter {
    name   = "attachment.vpc-id" # VPC에 연결된 것을 기준으로 필터링
    values = [var.vpc_id]        # 해당 VPC ID 지정
  }
}
