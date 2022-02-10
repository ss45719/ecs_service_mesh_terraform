# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# public route table and routes
# private route table and routes
# public and private subnets
# internet gateway
# NAT gateway