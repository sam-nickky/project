resource "aws_security_group" "infra_sg" {
  name        = "infra_sg"
  description = "Security group for infrastructure"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }   

  tags = {
    Name        = "Infra Security Group"
    Environment = var.environment
  }   
}

output "sg_id" {
    value = aws_security_group.infra_sg.id
  
}