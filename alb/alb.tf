# Create the Application Load Balancer
resource "aws_lb" "main_alb" {
  name               = "main-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-05d4e2a15a46afc2c"] # Replace with your ALB Security Group ID
  subnets            = ["subnet-035c410a1f1692392", "subnet-07b45a2fbc00f0293"] # Replace with at least two public subnet IDs
}

# Create the Target Group listening on NodePort 30000
resource "aws_lb_target_group" "gateway_tg" {
  name        = "gateway-nodeport-tg"
  port        = 30000
  protocol    = "HTTP"
  vpc_id      = "vpc-0e15078505b936374" # Fixed: Wrapped in quotes
  target_type = "instance"

  health_check {
    path                = "/health" 
    port                = "30000"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Attach Worker Node 1
resource "aws_lb_target_group_attachment" "node1_attachment" {
  target_group_arn = aws_lb_target_group.gateway_tg.arn
  target_id        = "i-02daf09e736285c60" 
  port             = 30000
}

# Attach Worker Node 2
resource "aws_lb_target_group_attachment" "node2_attachment" {
  target_group_arn = aws_lb_target_group.gateway_tg.arn
  target_id        = "i-023ecc52926fe525f" 
  port             = 30000
}

# Create the ALB Listener to route traffic to the Target Group
resource "aws_lb_listener" "gateway_listener" {
  load_balancer_arn = aws_lb.main_alb.arn # Fixed: Reference now exists
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_tg.arn
  }
}
