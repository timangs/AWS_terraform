resource "aws_db_instance" "rds_mysql1" {
  # DB 식별자
  identifier             = "database-1"

  # 엔진 옵션
  engine                 = "mysql"
  engine_version         = "8.0.40"

  # 인스턴스 구성
  instance_class         = "db.t3.micro"

  # 스토리지
  storage_type           = "gp3"
  allocated_storage      = 20

  # 자격 증명
  username               = "admin"
  password               = "timangs123"

  # 연결
  vpc_security_group_ids = [aws_security_group.rds_mysql1.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_mysql1.name

  # Enhanced Monitoring 설정
  # monitoring_interval = 60
  # monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn # 생성한 IAM 역할의 ARN


  multi_az               = true
  publicly_accessible    = false
  # 만약 skip_final_snapshot가 false면 final_snapshot_identifier = "database-1-final-snapshot-20240307"  
  db_name                = "sqlDB"  
  parameter_group_name = aws_db_parameter_group.rds_mysql1.name
  apply_immediately          = true # 수정 즉시적용
  backup_retention_period = 0 # 백업 보존 기간
  deletion_protection    = false  # 삭제 방지 설정
  skip_final_snapshot = true # 최종 스냅샷 설정

  #로그 설정
  # enabled_cloudwatch_logs_exports = ["error", "general"]

}

# IAM Role 생성 (Enhanced Monitoring 역할)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy Attachment 
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring_attachment" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_db_subnet_group" "rds_mysql1" {
  name       = "main-db-subnet-group" 
  subnet_ids = data.aws_subnets.rds_mysql1.ids
  tags = {
    Name = "My DB subnet group"
  }
}

data "aws_subnets" "rds_mysql1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.rds_mysql1.id]
  }
}

resource "aws_security_group" "rds_mysql1" {
  name        = "rds_sg"
  description = "Security group for RDS"
  vpc_id      = data.aws_vpc.rds_mysql1.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

data "aws_vpc" "rds_mysql1" {
  default = true
}

resource "aws_db_parameter_group" "rds_mysql1" {
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