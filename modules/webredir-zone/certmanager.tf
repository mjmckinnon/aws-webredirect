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

# Create a DNS record for validation of example.com
resource "aws_route53_record" "root_validation_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.domain.zone_id
  ttl = 60
  type = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  name = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  records = [ tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value ]
}

# Create a DNS record for validation of www.example.com
resource "aws_route53_record" "www_validation_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.domain.zone_id
  ttl = 60
  type = tolist(aws_acm_certificate.certificate.domain_validation_options)[1].resource_record_type
  name = tolist(aws_acm_certificate.certificate.domain_validation_options)[1].resource_record_name
  records = [ tolist(aws_acm_certificate.certificate.domain_validation_options)[1].resource_record_value ]
}

# Performs the DNS based validation by creating temporary
# DNS entries for a delegated domain
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    aws_route53_record.root_validation_record.fqdn,
    aws_route53_record.www_validation_record.fqdn
  ]  
}

# Find the Port 443 listener on the load balancer
data "aws_lb_listener" "listener" {
  arn = var.https_listener_arn
}

# Need to add the certificate to the loadbalancer
resource "aws_lb_listener_certificate" "bindcert" {
  depends_on = [aws_acm_certificate_validation.validation]
  certificate_arn = aws_acm_certificate.certificate.arn
  listener_arn = data.aws_lb_listener.listener.arn
}
