variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  
}

variable "environment" {
  description = "Environment for the VPC"
  type        = string
  default     = "Test"  
  
}

