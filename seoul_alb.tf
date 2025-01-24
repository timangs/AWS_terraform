resource "aws_lb" "seoul" {
  provider = aws.seoul
  name               = "seoul-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.seoul.id]
  subnets            = [
    aws_subnet.seoul["sn1"].id,
    aws_subnet.seoul["sn2"].id
  ]
  enable_deletion_protection = false
}
resource "aws_lb_target_group" "seoul" {
  provider = aws.seoul
  name     = "seoul-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.seoul.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}
resource "aws_lb_listener" "seoul" {
  provider = aws.seoul
  load_balancer_arn = aws_lb.seoul.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.seoul.arn
  }
}
resource "aws_lb_target_group_attachment" "seoul" {
  provider = aws.seoul
  for_each          = {
    seoul_pr1 = aws_instance.seoul_pri1.id
    seoul_pr2 = aws_instance.seoul_pri2.id
  }
  target_group_arn = aws_lb_target_group.seoul.arn
  target_id        = each.value
  port             = 80
}
