
output "loadbalancer_arn" {
  value = aws_lb.web_redir.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.web_redir_https.arn
}