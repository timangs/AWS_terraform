resource "aws_rds_global_cluster" "default" {
  global_cluster_identifier = "my-global-database" 
  engine                    = "aurora-postgresql"
  engine_version            = "16.4"
  database_name             = "sqlDB"
  storage_encrypted         = false 
  deletion_protection       = false 
}

# 서울 리전 - Primary
resource "aws_rds_cluster" "primary" {
  cluster_identifier            = "aurora-postgresql-cluster-seoul"
  engine                        = aws_rds_global_cluster.default.engine
  engine_version                = aws_rds_global_cluster.default.engine_version
  database_name                 = aws_rds_global_cluster.default.database_name
  master_username               = "psqladm"
  master_password               = "Timangs~123" 
  skip_final_snapshot           = true
  apply_immediately             = true
  db_subnet_group_name          = aws_db_subnet_group.aurora_db_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.allow_db_access.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster.name
  global_cluster_identifier     = aws_rds_global_cluster.default.id 
    tags = {
    Name = "aurora-postgresql-cluster-seoul"
  }
}

resource "aws_rds_cluster_instance" "primary_instance" {
  count              = 2
  cluster_identifier = aws_rds_cluster.primary.id
  identifier         = "aurora-postgresql-instance-seoul-${count.index}"
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
  publicly_accessible = false
    tags = {
    Name = "aurora-instance-seoul"
  }
}

# 싱가포르 리전 리소스
resource "aws_rds_cluster" "secondary" {
  provider                  = aws.si
  cluster_identifier            = "aurora-postgresql-cluster-singapore"
  engine                        = aws_rds_global_cluster.default.engine
  engine_version                = aws_rds_global_cluster.default.engine_version
  skip_final_snapshot           = true
  apply_immediately             = true
  db_subnet_group_name          = aws_db_subnet_group.aurora_db_subnet_group2.name
  vpc_security_group_ids       = [aws_security_group.allow_db_access2.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster2.name
  global_cluster_identifier     = aws_rds_global_cluster.default.id 

  depends_on = [aws_rds_cluster_instance.primary_instance] 
    tags = {
    Name = "aurora-postgresql-cluster-singapore"
  }
}

resource "aws_rds_cluster_instance" "secondary_instance" {
  provider           = aws.si 
  count              = 2
  cluster_identifier = aws_rds_cluster.secondary.id
  identifier         = "aurora-postgresql-instance-singapore-${count.index}"
  instance_class     = "db.r5.large" 
  engine             = aws_rds_cluster.secondary.engine
  engine_version     = aws_rds_cluster.secondary.engine_version
  publicly_accessible = false
    tags = {
    Name = "aurora-instance-singapore"
  }
}


resource "aws_rds_cluster_parameter_group" "aurora_cluster" {
  name        = "aurora-postgresql-parameter-group" 
  family      = "aurora-postgresql16"    
  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }
  parameter {
    name  = "lc_messages"
    value = "ko_KR.UTF-8" 
    apply_method = "pending-reboot"
  }
  tags = {
    Name = "aurora-pg-param-group"
  }
}



resource "aws_rds_cluster_parameter_group" "aurora_cluster2" {
  provider = aws.si
  name        = "aurora-postgresql-parameter-group2" 
  family      = "aurora-postgresql16"    
  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }
  parameter {
    name  = "lc_messages"
    value = "ko_KR.UTF-8" 
    apply_method = "pending-reboot"
  }
  tags = {
    Name = "aurora-pg-param-group"
  }
}
