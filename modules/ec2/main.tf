resource "aws_instance" "infra_vm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.aws_subnet.infra_public[0].id
  security_groups = [module.sg_module.security_group_id]

#  security_groups = [aws_security_group.infra_sg.name]
  key_name        = var.key_name

  tags = {
    Name        = "Infra VM"
    Environment = var.environment
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

