################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Whether to create the cluster resources."
  type        = bool
  default     = true
}

variable "create_node_group" {
  description = "Whether to create the default managed node group."
  type        = bool
  default     = true
}

################################################################################
# Naming
################################################################################

variable "name" {
  description = "Base name prefix for cluster resources."
  type        = string
}

################################################################################
# Networking
################################################################################

variable "vpc_id" {
  description = "VPC ID used by the cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the cluster."
  type        = list(string)
}

variable "cluster_api_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to reach the private EKS API."
  type        = list(string)
}

################################################################################
# EKS
################################################################################

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "eks_node_instance_type" {
  description = "Instance type for the default node group."
  type        = string
}

variable "eks_node_desired_size" {
  description = "Desired size of the default node group."
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum size of the default node group."
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum size of the default node group."
  type        = number
}

variable "eks_node_ami_id" {
  description = "AMI ID for the EKS managed node group."
  type        = string
}

variable "eks_node_ami_type" {
  description = "AMI type for the EKS managed node group."
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
}

################################################################################
# Security
################################################################################

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary applied to cluster IAM roles."
  type        = string
}

variable "iam_role_path" {
  description = "Path of the IAM role. If not specified then the default of '/' is used."
  type        = string
  default     = "/"
}

variable "kms_key_id" {
  description = "KMS key used for cluster secret encryption."
  type        = string
}

variable "oidc_thumbprints" {
  description = "Custom OIDC root CA thumbprints. Required when include_oidc_root_ca_thumbprint is false."
  type        = list(string)
  default     = []
}
