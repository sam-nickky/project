module "network" {
  source              = "./modules/network"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}


# Security group for ASG instances allowing HTTP and SSH (example)
resource "aws_security_group" "asg_sg" {
  name        = "asg-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH (lock down in prod!)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-instance-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "example-alb"
  load_balancer_type = "application"
  subnets            = module.network.public_subnet_ids
  security_groups    = [aws_security_group.asg_sg.id]

  tags = {
    Name = "example-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name_prefix = "apptg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.network.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

module "asg" {
  source              = "./modules/asg"
  name                = "webapp"
  ami_id              = var.ami_id
  instance_type        = var.instance_type
  subnet_ids          = module.network.public_subnet_ids
  security_group_ids  = [aws_security_group.asg_sg.id]
  instance_profile_name = module.iam.instance_profile_name
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_id              = module.network.vpc_id
  # We want the ASG to attach to the target group we created here instead of its own placeholder.
  # So override by importing or adjusting module; simplest is to expose target group ARN via variable if making flexible.
}

# Optional: output the ALB DNS name to hit
output "alb_dns" {
  value = aws_lb.alb.dns_name
}

module "s3" {
  source = "./modules/s3"
  name   = "webapp"
}

module "iam" {
  source                = "./modules/iam-instance-profile"
  instance_profile_name = "ec2-profile"
  log_bucket_name       = module.s3.bucket_name
}
module "eks" {
  source                 = "./modules/eks"
  cluster_name           = "example-eks-cluster"
  cluster_version        = "1.29"
  subnet_ids             = module.network.public_subnet_ids
  vpc_id                 = module.network.vpc_id
  eks_role_arn           = module.iam.eks_role_arn
  node_group_role_arn    = module.iam.node_group_role_arn
}
