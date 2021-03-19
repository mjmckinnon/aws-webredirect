
# The Application Load Balancer
resource "aws_lb" "web_redir" {
  name = "web-redir-lb"
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups = [aws_security_group.web_redir.id]
  enable_deletion_protection = true
  access_logs {
    bucket = aws_s3_bucket.log_bucket.bucket
    prefix = "alb-logs"
    enabled = true
  }
}

# Setup a target group for our lambda function
resource "aws_lb_target_group" "web_redir" {
  name = "webredir-target-group"
  target_type = "lambda"
}

# Attach the lambda function to the target group
resource "aws_lb_target_group_attachment" "web_redir" {
  target_group_arn = aws_lb_target_group.web_redir.arn
  target_id = aws_lambda_function.web_redir_lambda.arn
  depends_on = [aws_lambda_permission.web_redir]
}

# Add a listener on Port 80 (HTTP)
resource "aws_lb_listener" "web_redir_http" {
  load_balancer_arn = aws_lb.web_redir.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_redir.arn
  }
}

# Add a listener on Port 443 (HTTPS) with our default SSL Certificate
# additional sites that we add will use aws_lb_listener_certificate
resource "aws_lb_listener" "web_redir_https" {
  load_balancer_arn = aws_lb.web_redir.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_redir.arn
  }
}
