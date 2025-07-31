variable "vpc_id" {
    description = "ID of the VPC where the subnet will be created"
    type        = string
}

variable "availability_zone" {
    description = "Availability zone for the subnet"
    type        = string
    default     = ["eu-north-1a, eu-north-1b"]
}
variable "environment" {
    description = "Environment for the VPC"
    type        = string
    default     = "Test"
}
variable "public_subnet_cidr" {
    description = "CIDR block for the public subnet"
    type        = string
    default     = ["10.0.1.0/24, 10.0.2.0/24"]
  
}
variable "private_subnet_cidr" {
    description = "CIDR block for the private subnet"
    type        = string
    default     = ["10.0.10.0/24, 10.0.20.0/24"]
}