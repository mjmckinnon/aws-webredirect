# Purpose: Issue certificate for the primary zone belonging to the web redirector

# Issue an SSL Certificate for CN=example.com, Alt=www.example.com
resource "aws_acm_certificate" "certificate" {
  domain_name       = aws_route53_zone.primary_zone.name
  subject_alternative_names = ["www.${aws_route53_zone.primary_zone.name}"]
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
  zone_id         = aws_route53_zone.primary_zone.zone_id
}

# Performs the DNS based validation by creating temporary
# DNS entries for a delegated domain
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validate_record : record.fqdn]
}
