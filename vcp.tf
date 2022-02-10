# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.default_tags.project}-vpc"
  }
  assign_generated_ipv6_cidr_block = true
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.main.id
  # 10.255.0.0/20 --> 10.255.0.0/24
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  tags = {
      "Name" ="${var.default_tags.project}-public-${data.aws_availability_zones.available.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.project}-public-route-table"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main
  tags = {
    "Name" = "${var.default_tags.project}-igw"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id ,count.index) #element is function to add all values 
  route_table_id = aws_route_table.public.id
}



# public subnet $ private subnet
# public route table and routes
# private route table and routes
# public and private subnets
# internet gateway
# NAT gateway
# route table association with public subnet

# private subnet
#private route table and route
# net gateway
# eip 

resource "aws_subnet" "private" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  # 10.255.0.0/20 --> 10.255.0.0/24
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + var.public_subnet_count) #we do not want to override cidr block
  tags = {
      "Name" ="${var.default_tags.project}-public-${data.aws_availability_zones.available.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.project}-private-route-table"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    "Name" = "value"
  }
}
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.0.id
  tags = {
    "Name" = "value"
  }
  depands_on = [aws_eip.nat, aws_internet_gateway.gw]
}

resource "aws_route" "private_internet_access" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat-gateway.id
}

resource "aws_route_table_association" "private" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id ,count.index) #element is function to add all values 
  route_table_id = aws_route_table.private.id
}

/*
Neil C. mostly there aren't many differences in GW configuration, probably in egress pricing :) but most of the config is the same. Generate new IP addresses, assign new Instance Groups with Virtual Machine, and modify sysctl with ipv4.forward = 1 and iptables to allow SRCNAT and basically that's all . And of course route table modification with next hoop to instance groups with those dynamic previous virtual machine. And that's all. Well documented in GCP docs */