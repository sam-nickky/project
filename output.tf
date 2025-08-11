output "asg_name" {
  value = module.asg.asg_name
}

output "alb_url" {
  value = aws_lb.alb.dns_name
}
output "asg_instance_profile_name" {
  value = module.iam.instance_profile_name
}
