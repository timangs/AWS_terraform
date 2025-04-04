# --- ECS Task용 보안 그룹 (ELK 스택용) ---
resource "aws_security_group" "elk_ecs_tasks_sg" {
  name        = "${var.h}-elk-ecs-tasks-sg"
  description = "Security group for ELK Stack ECS tasks"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [
        {port=9200, protocol="tcp", cidr=["0.0.0.0/0"]},
        {port=5000, protocol="tcp", cidr=["0.0.0.0/0"]},
        {port=9600, protocol="tcp", cidr=["0.0.0.0/0"]},
        {port=5601, protocol="tcp", cidr=["0.0.0.0/0"]},
        {port=443, protocol="tcp", cidr=["0.0.0.0/0"]},
        {port=-1, protocol="icmp", cidr=["0.0.0.0/0"]}
    ]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kibana_lb_sg" {
  name        = "${var.h}kibana_lb_sg"
  description = "Security group for Kibana ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [
      {port=80, protocol="tcp", cidr=["0.0.0.0/0"]},
      {port=443, protocol="tcp", cidr=["0.0.0.0/0"]},
    ]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.h}kibana_lb_sg"
  }
}
