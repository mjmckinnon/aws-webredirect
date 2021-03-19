
# Conditionally refer to an existing route53 zone
data "aws_route53_zone" "domain" {
  zone_id = var.zone_id
}

# Reference to the existing loadbalancer by its ARN
data "aws_lb" "loadbalancer" {
  arn = var.loadbalancer_arn
}

# Add CNAME for WWW that points to load balancer
# e.g. www.example.com CNAME example.com
resource "aws_route53_record" "domain_www" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "www.${data.aws_route53_zone.domain.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_route53_zone.domain.name]
}

# Add zone record that points to the load balancer
# e.g. example.com A [points to load balancer]
resource "aws_route53_record" "primary_lb" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = data.aws_route53_zone.domain.name
  type    = "A"
  alias {
    name = data.aws_lb.loadbalancer.dns_name
    zone_id = data.aws_lb.loadbalancer.zone_id
    evaluate_target_health = false
  }
}
