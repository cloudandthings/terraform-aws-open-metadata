################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Whether to create access resources."
  type        = bool
  default     = true
}

################################################################################
# Cluster Context
################################################################################

variable "cluster_name" {
  description = "Cluster name used for access entries."
  type        = string
}

################################################################################
# Access Policies
################################################################################

variable "cluster_access_principals" {
  description = "Keyed map of principals that should get cluster-scoped access."
  type = map(object({
    principal_arn = string
    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")
  }))
  default = {}
}

variable "namespace_access_principals" {
  description = "Keyed map of principals that should get namespace-scoped access."
  type = map(object({
    principal_arn = string
    namespaces    = list(string)
    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy")
  }))
  default = {}
}
