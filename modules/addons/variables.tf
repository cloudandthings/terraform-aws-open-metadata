################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Whether to create addon resources."
  type        = bool
  default     = true
}

variable "create_aws_load_balancer_controller" {
  description = "Whether to install the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "create_external_secrets_operator" {
  description = "Whether to install the External Secrets Operator."
  type        = bool
  default     = true
}

variable "aws_lb_controller_chart_version" {
  description = "Helm chart version for the AWS Load Balancer Controller."
  type        = string
  default     = "3.1.0"
}

variable "external_secrets_chart_version" {
  description = "Helm chart version for the External Secrets Operator."
  type        = string
  default     = "2.2.0"
}

################################################################################
# Cluster Context
################################################################################

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN used by the addon IRSA role."
  type        = string
  default     = null
}

################################################################################
# AWS Context, Naming, And IAM
################################################################################

variable "region" {
  description = "AWS region."
  type        = string
}

variable "name_prefix" {
  description = "Short prefix for addon IAM resources."
  type        = string
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary applied to addon IAM roles."
  type        = string
}

variable "iam_role_path" {
  description = "Path of the IAM role. If not specified then the default of '/' is used."
  type        = string
  default     = "/"
}

################################################################################
# Networking
################################################################################

variable "vpc_id" {
  description = "VPC ID used by the AWS Load Balancer Controller."
  type        = string
}
