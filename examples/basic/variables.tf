variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region for the deployment"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the cluster and data plane"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS and data-plane services"
  type        = list(string)
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for IAM roles"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID or ARN for data-plane encryption"
  type        = string
}

variable "eks_node_ami_id" {
  description = "AMI ID for the EKS managed node group"
  type        = string
}
