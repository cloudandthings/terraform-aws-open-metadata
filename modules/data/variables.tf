################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Whether to create data-plane resources."
  type        = bool
  default     = true
}

variable "create_rds" {
  description = "Whether to create the PostgreSQL database."
  type        = bool
  default     = true
}

variable "create_rds_secret" {
  description = "Whether to create the RDS credentials secret."
  type        = bool
  default     = true
}

variable "create_opensearch" {
  description = "Whether to create the OpenSearch domain."
  type        = bool
  default     = true
}

variable "create_opensearch_secret" {
  description = "Whether to create the OpenSearch credentials secret."
  type        = bool
  default     = true
}

################################################################################
# AWS Context And Naming
################################################################################

variable "region" {
  description = "AWS region."
  type        = string
}

variable "account_id" {
  description = "AWS account ID used in the OpenSearch access policy."
  type        = string
}

variable "name" {
  description = "Base name prefix for data-plane resources."
  type        = string
}

variable "name_prefix" {
  description = "Short prefix for OpenSearch naming."
  type        = string
}

################################################################################
# Networking
################################################################################

variable "vpc_id" {
  description = "VPC ID used by the data plane."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the data plane."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Node security group ID allowed to reach the data plane."
  type        = string
  default     = null
}

variable "rds_ingress_cidr_blocks" {
  description = "Additional CIDR blocks allowed to reach the RDS instance on port 5432. Useful for direct database access from a bastion or developer machine."
  type        = list(string)
  default     = []
}

################################################################################
# Security
################################################################################

variable "kms_key_id" {
  description = "KMS key used for encryption at rest."
  type        = string
}

variable "secrets_kms_key_id" {
  description = "KMS key ID or ARN used to encrypt AWS Secrets Manager secrets."
  type        = string
  default     = null
}

################################################################################
# RDS
################################################################################

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "rds_family" {
  description = "Parameter group family for PostgreSQL."
  type        = string
}

variable "rds_allocated_storage" {
  description = "Allocated RDS storage in GB."
  type        = number
}

variable "database_name" {
  description = "Database name for OpenMetadata."
  type        = string
}

variable "database_username" {
  description = "Master username for RDS."
  type        = string
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ on RDS."
  type        = bool
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final snapshot on deletion."
  type        = bool
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection on RDS."
  type        = bool
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS automated backups. Set to 0 to disable backups."
  type        = number
  default     = 7
}

################################################################################
# OpenSearch
################################################################################

variable "opensearch_engine_version" {
  description = "OpenSearch engine version."
  type        = string
}

variable "opensearch_instance_type" {
  description = "OpenSearch node instance type."
  type        = string
}

variable "opensearch_instance_count" {
  description = "OpenSearch data node count."
  type        = number
}

variable "opensearch_ebs_volume_size" {
  description = "OpenSearch EBS volume size in GB."
  type        = number
}

variable "opensearch_master_username" {
  description = "OpenSearch master username."
  type        = string
}

################################################################################
# Existing Resource Overrides
################################################################################

variable "existing_rds_endpoint" {
  description = "Existing RDS host or endpoint used when create_rds is false."
  type        = string
  default     = null
}

variable "existing_rds_secret_arn" {
  description = "Existing RDS secret ARN used when create_rds is false."
  type        = string
  default     = null
}

variable "existing_opensearch_endpoint" {
  description = "Existing OpenSearch endpoint used when create_opensearch is false."
  type        = string
  default     = null
}

variable "existing_opensearch_secret_arn" {
  description = "Existing OpenSearch secret ARN used when create_opensearch is false."
  type        = string
  default     = null
}
