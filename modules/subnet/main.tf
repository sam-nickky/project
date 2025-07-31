# VPC Module (assumed to be defined elsewhere and outputs vpc_id)
module "vpc" {
  source = "./modules/vpc"
  # Make sure this module outputs `vpc_id`
}

# PUBLIC SUBNETS
resource "aws_subnet" "infra_public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public Subnet ${count.index + 1}"
    Environment = var.environment
  }
}

# PRIVATE SUBNETS
resource "aws_subnet" "infra_private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name        = "Private Subnet ${count.index + 1}"
    Environment = var.environment
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "IGW"
  }
}

# ELASTIC IP for NAT
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "NAT EIP"
  }
}

# NAT GATEWAY in PUBLIC subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.infra_public[0].id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# PUBLIC SUBNET ASSOCIATION
resource "aws_route_table_association" "public" {
  for_each = { for idx, subnet in aws_subnet.infra_public : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# PRIVATE SUBNET ASSOCIATION
resource "aws_route_table_association" "private" {
  for_each = { for idx, subnet in aws_subnet.infra_private : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
