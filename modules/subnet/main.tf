resource "aws_subnet" "infra_public" {
  count                  = length(var.public_subnet_cidr)
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public Subnet"
    Environment = var.environment
  }
  
}
resource "aws_subnet" "infra_private" {
  count = length(var.private_subnet_cidr)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name        = "Private Subnet"
    Environment = var.environment
  }
  
}

