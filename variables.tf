variable "aws_account" {
  description = "AWS account to deploy resources"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "backup_plan_name" {
  description = "Backup plan name"
  type        = string
}

variable "backup_rule_1" {
  description = "Backup rule name"
  type        = string
}

variable "backup_vault_name" {
  description = "Backup vault name"
  type        = string
}

variable "schedule" {
  description = "Backup schedule as cron expression (e.g. 'cron(0 12 * * ? *)')"
  type        = string
}

variable "lifecycle_rule" {
  description = "Delete backups after _ days"
  type        = number
}

variable "backup_selection" {
  description = "Resources to backup"
  type        = string
}

variable "backup_tag_value" {
  description = "Tag value for aws resources that will be backed up by this plan"
  type        = string
}