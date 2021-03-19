
# Settings used throughout to define a few things

# ------------------------------------------------------------------------------------------------ #
# Required

variable "delegation_set_id" {
  type = string
  description = "AWS ID of an existing name server delegation set"
}

# Reference name for the Delegation Set (default)
variable "reference_name" {
  default = "WebRedir-NameServers"
}

variable "primary_domain_name" {
  type = string
  description = "Domain Name that will be created and used with the web redirector"
}

variable "redirection_csv_file" {
  type = string
  description = "Reference to redirections.csv rules file"
}

# ------------------------------------------------------------------------------------------------ #
# Optional

variable "vip_cidr_block" {
  # This should be a /16 and it gets carved into X.X.1.0/24 (Subnet1) and X.X.2.0/24 (Subnet2)
  default = "10.10.0.0/16"
}

variable "system_description" {
  # Default name of this web redirection system
  # is used in the description of various things
  default = "Web Redirector"
}
