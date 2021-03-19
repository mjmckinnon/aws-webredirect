
output "nameservers" {
  value = aws_route53_delegation_set.nameservers
  description = "Please re-delegate your domains to these Name Servers ASAP"
}
