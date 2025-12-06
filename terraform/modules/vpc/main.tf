# VPC 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-VPC"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# Define Availability Zones for subnets
data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets (for ALB and NAT Gateway) [cite: 11, 13]
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index) # 10.0.0.0/24, 10.0.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Instances in public subnets need public IP

  tags = {
    Name    = "${var.project_name}-PublicSubnet-${count.index + 1}"
    Tier    = "Public"
  }
}

# Private Subnets (for EC2/ASG) [cite: 11, 17, 32]
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index + 2) # 10.0.2.0/24, 10.0.3.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # No public IPs for EC2 

  tags = {
    Name    = "${var.project_name}-PrivateSubnet-${count.index + 1}"
    Tier    = "Private"
  }
}

# EIP for NAT Gateway
resource "aws_eip" "nat" {
  count      = 1 # One NAT Gateway for simplicity
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-EIP"
  }
}

# NAT Gateway (in one public subnet) [cite: 13]
resource "aws_nat_gateway" "nat_gw" {
  count         = 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[0].id # Place NAT in the first public subnet
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-NAT-GW"
  }
}

# --- Route Tables ---

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-Public-RT"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[0].id # Route all egress traffic through NAT GW 
  }

  tags = {
    Name = "${var.project_name}-Private-RT"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}