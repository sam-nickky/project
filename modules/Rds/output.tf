output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_instance_arn" {
  value = aws_db_instance.this.arn
}

output "address" {
  description = "DNS address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "username" {
  value     = var.username
  sensitive = true
}

output "security_group_id" {
  value = var.create_security_group ? aws_security_group.this[0].id : null
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "secret_arn" {
  value     = length(aws_secretsmanager_secret.db) > 0 ? aws_secretsmanager_secret.db[0].arn : null
  sensitive = true
}
