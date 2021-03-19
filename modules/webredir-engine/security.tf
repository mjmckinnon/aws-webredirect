# A Security Group for open access to HTTPS for the Load Balancer
resource "aws_security_group" "web_redir" {
  vpc_id = aws_vpc.main.id
  name = "web-redirector-secgroup"
  description = "Web Redirect - allow web traffic"
  ingress {
    description = "Allow all HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_any_web_traffic"
  }
}
