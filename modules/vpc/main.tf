resource "aws_vpc" "Infra_vpc" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "Infra VPC"
        Environment = var.environment
    }
}

output "vpc_id" {
    value = aws_vpc.Infra_vpc.id
  
}