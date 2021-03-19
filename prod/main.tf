# Amazon AWS
provider "aws" {
  region = "ap-southeast-2"
}

# =================================== #
# This is the default domain name used
# for your web redirect engine (change it):

locals {
  my_domain_name = "example.com"
}
# =================================== #

# We want some reusable name servers to delegate domains to for web redirection
resource "aws_route53_delegation_set" "nameservers" {
  lifecycle {
    prevent_destroy = true
  }
}

# --------------------------------------------------------------------#
# Main Web Redirection with a mandatory "Primary" Domain

module "webredirengine" {
  source = "../modules/webredir-engine"

  # The Primary Domain is always added to Route53, make sure
  # this domain isn't already in your AWS account
  primary_domain_name = local.my_domain_name

  # This is the rules file, you can edit this any time and
  # re-apply to upload when this is all up and running
  redirection_csv_file = "${path.module}/redirections.csv"

  # (Optional) The system description is used to label and name objects in your AWS account
  # system_description = "My Web Redirector"

  # (Optional) We create a new VPC, you can specific your own /16
  # vip_cidr_block = "10.10.0.0/16"

  delegation_set_id = aws_route53_delegation_set.nameservers.id
}

# --------------------------------------------------------------------#
# Add an NEW domain (not yet added in Route53) by adding this:
# (change all example references)

#resource "aws_route53_zone" "example" {
#  name = "example.com"
#  delegation_site_id = aws_route53_delegation_set.nameservers.id
#}

#module "example" {
#  source = "../modules/webredir-zone"
#  zone_id = data.aws_route53_zone.example.zone_id
#  loadbalancer_arn = module.webredirengine.loadbalancer_arn
#  https_listener_arn = module.webredirengine.https_listener_arn
#}

# --------------------------------------------------------------------#
# Add an EXISTING domain (already in Route53) by adding this:
# (change all example references)

#data "aws_route53_zone" "example" {
#  zone_id = "NE2938H983F098D97BC" # example zone_id, if you have it; otherwise
#  name = "example.com"            # use name; but only use one.
#}

# Additional domain
#module "example" {
#  source = "../modules/webredir-zone"
#  zone_id = data.aws_route53_zone.example.zone_id
#  loadbalancer_arn = module.webredirengine.loadbalancer_arn
#  https_listener_arn = module.webredirengine.https_listener_arn
#}
# --------------------------------------------------------------------#
