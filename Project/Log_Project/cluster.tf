# ECS cluster and Task definition (ELK) 
# IAM role for ECS Task

resource "aws_ecs_cluster" "log" {
  name = "${var.h}cluster"
  tags = {
    Name = "${var.h}cluster"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.h}ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "log" {
  family                   = "${var.h}task" 
  network_mode             = "awsvpc"   
  requires_compatibilities = ["FARGATE"]   
  cpu                      = 4096        
  memory                   = 8192       
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "ElasticSearch"
      image     = var.elastic_url
      cpu       = 2048
      memory    = 4096
      essential = true
      portMappings = [
        {
          containerPort = 9200
          hostPort      = 9200
        }
      ]
      # 로그 설정 등 추가 가능
      # logConfiguration = { ... }
    },
    {
      name      = "Logstash"
      image     = var.logstash_url
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        },
        {
          containerPort = 9600
          hostPort      = 9600
        }
      ]
      # 로그 설정 등 추가 가능
      # logConfiguration = { ... }
    },
    {
      name      = "Kibana"
      image     = var.kibana_url
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 5601
          hostPort      = 5601
        }
      ]
      # 로그 설정 등 추가 가능
      # logConfiguration = { ... }
    }
  ])

  tags = {
    Name = "${var.h}task"
  }
}

resource "aws_lb" "kibana_lb" {
  name               = "${var.h}kibana-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kibana_lb_sg.id]
  subnets = [
    aws_subnet.log[4].id,
    aws_subnet.log[5].id,
  ]
  enable_deletion_protection = false 
  tags = {
    Name = "${var.h}kibana_alb"
  }
}

resource "aws_lb_target_group" "kibana_tg" {
  name        = "${var.h}kibana-tg"
  port        = 5601 
  protocol    = "HTTP" 
  vpc_id      = var.vpc_id
  target_type = "ip" 

  health_check {
    enabled             = true
    path                = "/api/status" 
    protocol            = "HTTP"
    port                = "traffic-port" 
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.h}kibana_tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.kibana_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana_tg.arn
  }
}

resource "aws_ecs_service" "log" {
  name            = "${var.h}elk-service"    
  cluster         = aws_ecs_cluster.log.id     
  task_definition = aws_ecs_task_definition.log.arn 
  desired_count   = 1        
  launch_type = "FARGATE"     
  network_configuration {
    subnets = [
      aws_subnet.log[0].id,
      aws_subnet.log[1].id,
      aws_subnet.log[2].id,
      aws_subnet.log[3].id,
    ]
    assign_public_ip = false
    security_groups = [aws_security_group.elk_ecs_tasks_sg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
  load_balancer {
    target_group_arn = aws_lb_target_group.kibana_tg.arn
    container_name   = "Kibana"
    container_port   = 5601
  }
  tags = {
    Name = "${var.h}elk-service"
  }
}