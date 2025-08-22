terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

# Generate password if none supplied
resource "random_password" "this" {
  count   = var.db_password == null && var.create_secret ? 1 : 0
  length  = 20
  special = true
}

# Optionally store the password in Secrets Manager
resource "aws_secretsmanager_secret" "db" {
  count                   = var.create_secret ? 1 : 0
  name                    = var.secret_name != null ? var.secret_name : "${var.name}-db-credentials"
  recovery_window_in_days = var.secret_recovery_window_days
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.username
    password = coalesce(var.db_password, (length(random_password.this) > 0 ? random_password.this[0].result : null))
    engine   = var.engine
    host     = null
    port     = null
    dbname   = var.db_name
  })
}

# Subnet group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

# Optional parameter group (skip if family not given)
resource "aws_db_parameter_group" "this" {
  count  = var.parameter_group_family == null ? 0 : 1
  name   = "${var.name}-pg"
  family = var.parameter_group_family
  tags   = var.tags

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# Security group (create or use existing)
resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS ${var.name}"
  vpc_id      = var.vpc_id
  tags        = var.tags

  # No ingress by default. Add via separate rules (or set allowed_cidr_blocks)
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group ? toset(var.allowed_cidr_blocks) : []
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count             = var.create_security_group ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# The RDS instance
resource "aws_db_instance" "this" {
  identifier                          = var.name
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class

  db_name                             = var.db_name
  username                            = var.username
  password                            = coalesce(var.db_password, (length(random_password.this) > 0 ? random_password.this[0].result : null))

  port                                = var.port
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  storage_type                        = var.storage_type
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id

  multi_az                            = var.multi_az
  publicly_accessible                 = var.publicly_accessible
  availability_zone                   = var.availability_zone

  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids

  parameter_group_name                = length(aws_db_parameter_group.this) > 0 ? aws_db_parameter_group.this[0].name : null

  backup_retention_period             = var.backup_retention_days
  backup_window                       = var.backup_window
  maintenance_window                  = var.maintenance_window

  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : "${var.name}-final-${replace(timestamp(), ":", "")}"

  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.performance_insights_kms_key_id

  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = var.monitoring_role_arn

  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  apply_immediately                   = var.apply_immediately

  tags = var.tags
}

# Update the secret with host/port after creation
resource "aws_secretsmanager_secret_version" "db_conn" {
  count     = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.username
    password = coalesce(var.db_password, (length(random_password.this) > 0 ? random_password.this[0].result : null))
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
  depends_on = [aws_db_instance.this]
}
