terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_lb_target_group" "web" {
  name_prefix = "web-"
  port        = 30000
  protocol    = "HTTP"
  vpc_id      = "vpc-0e15078505b936374"
  target_type = "instance"

  # Health check configuration
  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Time to drain connections on deregistration
  deregistration_delay = 60

  # Gradually ramp up traffic to new targets
  slow_start = 120

  tags = {
    Name = "web-target-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Register specific instances
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = "i-01531901dbc4048e8"
  port             = 30000
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = "i-06ef3dd40c05e3165"
  port             = 30000
}



# The Application Load Balancer
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-05d4e2a15a46afc2c"]
  subnets            = ["subnet-035c410a1f1692392", "subnet-07b45a2fbc00f0293"]

  tags = {
    Environment = "dev"
  }
}


# HTTPS listener - forward to the app target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}