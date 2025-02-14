resource "aws_db_instance" "default" {
  identifier             = "database-1"
  engine                 = "mysql"
  engine_version         = "8.0.40"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  username               = "admin"
  password               = "timangs123"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot = true
#   final_snapshot_identifier = "database-1-final-snapshot-20240307"  
  parameter_group_name = aws_db_parameter_group.default.name
  db_name                = "sqlDB"  
  deletion_protection    = false 
  apply_immediately          = true
}

 resource "aws_db_subnet_group" "default" {
   name       = "main-db-subnet-group" 
   subnet_ids = data.aws_subnets.default.ids
   tags = {
     Name = "My DB subnet group"
   }
 }
 data "aws_subnets" "default" {
   filter {
     name   = "vpc-id"
     values = [data.aws_vpc.default.id]
   }
 }

resource "aws_security_group" "default" {
  name        = "rds_sg"
  description = "Security group for RDS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_db_parameter_group" "default" {
  name   = "mysql80-parameter-group"
  family = "mysql8.0"

  parameter {
    name        = "time_zone"
    value       = "Asia/Seoul"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"  # 또는 utf8mb4_general_ci
  }
    parameter {
      name  = "character_set_client"
      value = "utf8mb4"
    }
   parameter {
      name  = "character_set_connection"
      value = "utf8mb4"
   }
   parameter {
      name  = "character_set_results"
      value = "utf8mb4"
    }
    parameter {
        name = "character_set_database"
        value = "utf8mb4"
    }
    parameter {
       name = "collation_connection"
       value = "utf8mb4_unicode_ci"
    }
}