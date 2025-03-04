data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg-"
  description = "Security group for web server instances"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = [
      { from = 53, to = 53, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { from = 53, to = 53, protocol = "udp", cidr = ["0.0.0.0/0"] },
      { from = 80, to = 80, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { from = 22, to = 22, protocol = "tcp", cidr = ["0.0.0.0/0"] }, # SSH.  Restrict in production!
      { from = -1, to = -1, protocol = "icmp", cidr = ["0.0.0.0/0"] }
    ]
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
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
    Name = "instance-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for the ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from anywhere"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg"
  }
}


resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "web-server-lt-"
  image_id      = var.se_ami2
  instance_type = "t3.micro"
  key_name      = var.se_key
  vpc_security_group_ids = [aws_security_group.instance_sg.id] # Corrected security group
  user_data     = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer-ASG"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "web-server-asg"
  launch_template {
        id      = aws_launch_template.web_server_lt.id
        version = "$Latest"
  }
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  health_check_type    = "EC2"  # Or "ELB" if using health checks from the ALB
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.web_server_tg.arn] # Corrected target group attachment
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "WebServer-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb" "web_server_alb" {
  name               = "web-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] # Corrected security group
  subnets            = data.aws_subnets.default.ids
  enable_deletion_protection = false

  tags = {
    Name = "web-server-alb"
  }
}

resource "aws_lb_target_group" "web_server_tg" {
  name_prefix = "wb-tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  target_type = "instance"
  tags = {
    Name = "web-server-tg"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_tg.arn
  }
}

# Scale Out Policy (CPU > 60%)
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1  
  cooldown               = 300
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"  
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"  
  statistic           = "Average"
  threshold           = "60" 

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]
  insufficient_data_actions = []  # Prevent flapping
}

# Scale In Policy (CPU < 20%)
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1 # Remove 1 instance
  cooldown               = 300
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  alarm_name          = "cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_server_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]
  insufficient_data_actions = [] # Prevent flapping
}
