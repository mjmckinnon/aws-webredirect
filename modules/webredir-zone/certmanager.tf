# Issue an SSL Certificate for CN=example.com, Alt=www.example.com
resource "aws_acm_certificate" "certificate" {
  domain_name       = data.aws_route53_zone.domain.name
  subject_alternative_names = ["www.${data.aws_route53_zone.domain.name}"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_route53_record.domain_www
  ]
}

# Special validation for getting certificates from AWS
# creates validation records in route53 for domain
resource "aws_route53_record" "validate_record" {
  for_each = {
  for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

# Performs the DNS based validation by creating temporary
# DNS entries for a delegated domain
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validate_record : record.fqdn]
}

# Find the Port 443 listener on the load balancer
data "aws_lb_listener" "listener" {
  arn = var.https_listener_arn
}

# Need to add the certificate to the loadbalancer
resource "aws_lb_listener_certificate" "bindcert" {
  certificate_arn = aws_acm_certificate.certificate.arn
  listener_arn = data.aws_lb_listener.listener.arn
}
