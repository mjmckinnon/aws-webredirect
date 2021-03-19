
# The name ID of the route53 zone
variable "zone_id" {
  type = string
  description = "AWS Zone ID of an existing Route53 domain (we will be replacing host and WWW records)"
}

# The ARN of the existing load balancer
variable "loadbalancer_arn" {
  type = string
  description = "Load Balancer ARN"
}

# The ARN of the HTTPS listener
variable "https_listener_arn" {
  type = string
  description = "The ARN for the HTTPS listener"
}