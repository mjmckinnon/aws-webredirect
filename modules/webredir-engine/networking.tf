
# Get availability zones for when we create subnets later
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a new VPC dedicated to Web Redirection
resource "aws_vpc" "main" {
  cidr_block = var.vip_cidr_block # i.e. 10.80.1.0/16
  assign_generated_ipv6_cidr_block = false
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.system_description} VPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.system_description} IGW"
  }
}

# Create a routing table on VPC with Internet Gateway
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 1) # i.e. 10.80.1.0/24
  assign_ipv6_address_on_creation = false
  tags = {
    Name = "${var.system_description} Subnet1"
  }
}

# Associate subnet with our route table (with Internet Gateway)
resource "aws_route_table_association" "inbound1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main.id
}

# Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 2) # i.e. 10.80.2.0/24
  assign_ipv6_address_on_creation = false
  tags = {
    Name = "${var.system_description} Subnet2"
  }
}

# Associate subnet with our route table (with Internet Gateway)
resource "aws_route_table_association" "inbound2" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_network_acl" "allowall" {
  vpc_id = aws_vpc.main.id
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}