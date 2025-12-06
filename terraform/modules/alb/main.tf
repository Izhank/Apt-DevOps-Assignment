# ALB 
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false # Public ALB [cite: 37]
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # ALB in public subnets 
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-ALB"
  }
}

# Target Group 
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 8080 # App port 
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" # Health check path 
    protocol            = "HTTP"
    port                = "8080"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-TargetGroup"
  }
}

# Listener (HTTP) 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}