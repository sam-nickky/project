variable "name" {
  description = "Base name / identifier for the RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version (e.g., 8.0.35 for MySQL, 15.5 for Postgres)"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Instance class, e.g., db.t4g.micro"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Optional DB password (if not provided and create_secret=true, a random one is generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "create_secret" {
  description = "If true, create a Secrets Manager secret (and generate password if not provided)"
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "Optional explicit name for the secret"
  type        = string
  default     = null
}

variable "secret_recovery_window_days" {
  description = "Secrets Manager recovery window in days"
  type        = number
  default     = 7
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (min 2 for Multi-AZ)"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the DB resides"
  type        = string
}

variable "create_security_group" {
  description = "Whether to create an SG for the DB"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Existing SG IDs to attach instead of creating one"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect (used only when create_security_group=true)"
  type        = list(string)
  default     = []
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., mysql8.0, postgres15). If null, the default parameter group is used."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Parameter overrides for the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "allocated_storage" {
  description = "Initial size in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Autoscaling upper bound in GiB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "gp2 | gp3 | io1"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 3306 # change to 5432 for Postgres in usage if needed
}

variable "publicly_accessible" {
  description = "Whether the DB has a public IP"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Prefer a specific AZ (optional)"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window, e.g., 02:00-03:00"
  type        = string
  default     = "02:00-03:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window, e.g., Sun:03:00-Sun:04:00"
  type        = string
  default     = "Sun:03:00-Sun:04:00"
}

variable "deletion_protection" {
  description = "Protect from deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for Performance Insights"
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (required if interval > 0)"
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Auto-apply minor engine upgrades"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately (may cause downtime)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
