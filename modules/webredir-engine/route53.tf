# Add a new route53 zone that we'll use with this web redirector
resource "aws_route53_zone" "primary_zone" {
  name = var.primary_domain_name
  delegation_set_id = var.delegation_set_id
}

# Add CNAME for WWW that points to load balancer
# e.g. www.example.com CNAME example.com
resource "aws_route53_record" "domain_www" {
  zone_id = aws_route53_zone.primary_zone.zone_id
  name    = "www.${aws_route53_zone.primary_zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_zone.primary_zone.name]
}

# Add zone record that points to the load balancer
# e.g. example.com A [points to load balancer]
resource "aws_route53_record" "primary_lb" {
  zone_id = aws_route53_zone.primary_zone.zone_id
  name    = aws_route53_zone.primary_zone.name
  type    = "A"
  alias {
    name = aws_lb.web_redir.dns_name
    zone_id = aws_lb.web_redir.zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_lb.web_redir]
}
