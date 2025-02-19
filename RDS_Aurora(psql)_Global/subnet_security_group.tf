data "aws_vpc" "default" {
  default = true 
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "aurora_db_subnet_group" {
  name       = "my-default-db-subnet-group" 
  subnet_ids = data.aws_subnets.default.ids
  tags = {
    Name = "My Default DB Subnet Group"
  }
}

# 방법 2: 새로운 Security Group 생성 (권장)
resource "aws_security_group" "allow_db_access" {
  name        = "allow-db-access-default-vpc"
  description = "Allow database access (default VPC)"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    description = "PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
      Name = "allow-db-access-sg-default-vpc"
    }
}



# ---- 싱가폴 ----
data "aws_vpc" "default2" {
  provider = aws.si
  default = true 
}

data "aws_subnets" "default2" {
  provider = aws.si
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default2.id]
  }
}

resource "aws_db_subnet_group" "aurora_db_subnet_group2" {
  provider = aws.si
  name       = "my-default-db-subnet-group2" 
  subnet_ids = data.aws_subnets.default2.ids
  tags = {
    Name = "My Default DB Subnet Group"
  }
}

resource "aws_security_group" "allow_db_access2" {
  provider = aws.si
  name        = "allow-db-access-default-vpc2"
  description = "Allow database access (default VPC)"
  vpc_id      = data.aws_vpc.default2.id 

  ingress {
    description = "PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
      Name = "allow-db-access-sg-default-vpc"
    }
}

