################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Whether to create app resources."
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace."
  type        = bool
  default     = true
}

variable "create_openmetadata_release" {
  description = "Whether to install the OpenMetadata Helm release."
  type        = bool
  default     = true
}

variable "create_ingress" {
  description = "Whether to create ingress, ALB security groups, DNS, and TLS resources."
  type        = bool
  default     = true
}

################################################################################
# Naming And Tags
################################################################################

variable "name" {
  description = "Base name prefix for app-owned resources."
  type        = string
}

variable "name_prefix" {
  description = "Short prefix for IRSA naming."
  type        = string
}

variable "tags" {
  description = "Tags applied to supported app resources."
  type        = map(string)
}

################################################################################
# Networking And Ingress
################################################################################

variable "vpc_id" {
  description = "VPC ID used by ALB-related resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the ALB."
  type        = list(string)
}

variable "ingress_cidr_blocks" {
  description = "CIDR ranges allowed inbound to the OpenMetadata ALB."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Node security group ID allowed to receive ALB traffic."
  type        = string
  default     = null
}

################################################################################
# TLS
################################################################################

variable "enable_tls" {
  description = "Whether to enable TLS for the ingress."
  type        = bool
  default     = false
}

variable "acm_private_ca_arn" {
  description = "Private CA ARN used to issue the ingress certificate."
  type        = string
  default     = null
}

variable "openmetadata_fqdn" {
  description = "Precomputed FQDN used for the ACM certificate."
  type        = string
  default     = null
}

################################################################################
# Kubernetes And Chart
################################################################################

variable "namespace" {
  description = "Kubernetes namespace for OpenMetadata."
  type        = string
}

variable "region" {
  description = "AWS region used by the External Secrets SecretStore."
  type        = string
}

variable "openmetadata_chart_version" {
  description = "OpenMetadata Helm chart version."
  type        = string
}

################################################################################
# Data Plane Connections
################################################################################

variable "database_host" {
  description = "Database host used by OpenMetadata."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Database name for OpenMetadata."
  type        = string
}

variable "database_username" {
  description = "Database username used by OpenMetadata."
  type        = string
}

variable "database_secret_arn" {
  description = "AWS Secrets Manager secret ARN used as the source for the OpenMetadata DB password."
  type        = string
  default     = null
}

variable "database_secret_ref" {
  description = "Kubernetes Secret name consumed by the OpenMetadata chart for the DB password (openmetadata.config.database.auth.password.secretRef)."
  type        = string
  default     = "openmetadata-db-secrets"
}

variable "database_secret_key" {
  description = "Key name created inside the Kubernetes Secret target (for example openmetadata-db-password). This is not the AWS Secrets Manager JSON property name."
  type        = string
  default     = "openmetadata-db-password"
}

variable "database_secret_property" {
  description = "Optional JSON property to extract from the AWS Secrets Manager secret value (remoteRef.property). Leave null when the secret value is already a plain string. Example: password."
  type        = string
  default     = null
}

variable "opensearch_endpoint" {
  description = "OpenSearch endpoint used by OpenMetadata."
  type        = string
  default     = null
}

variable "opensearch_master_username" {
  description = "OpenSearch username used by OpenMetadata."
  type        = string
}

variable "opensearch_secret_arn" {
  description = "AWS Secrets Manager secret ARN used as the source for the OpenSearch password."
  type        = string
  default     = null
}

variable "opensearch_secret_ref" {
  description = "Kubernetes Secret name consumed by the OpenMetadata chart for the OpenSearch password (openmetadata.config.elasticsearch.auth.password.secretRef)."
  type        = string
  default     = "openmetadata-opensearch-secrets"
}

variable "opensearch_secret_key" {
  description = "Key name created inside the Kubernetes Secret target (for example openmetadata-opensearch-password). This is not the AWS Secrets Manager JSON property name."
  type        = string
  default     = "openmetadata-opensearch-password"
}

variable "opensearch_secret_property" {
  description = "Optional JSON property to extract from the AWS Secrets Manager secret value (remoteRef.property). Leave null when the secret value is already a plain string. Example: password."
  type        = string
  default     = null
}

################################################################################
# IAM
################################################################################

variable "oidc_provider_arn" {
  description = "OIDC provider ARN used for the OpenMetadata IRSA role."
  type        = string
  default     = null
}

variable "openmetadata_heap_opts" {
  description = "JVM heap options passed to OpenMetadata via OPENMETADATA_HEAP_OPTS."
  type        = string
  default     = "-Xmx2G -Xms2G"
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary applied to app IAM roles."
  type        = string
}

variable "iam_role_path" {
  description = "Path of the IAM role. If not specified then the default of '/' is used."
  type        = string
  default     = "/"
}

################################################################################
# Generic OpenMetadata Helm Configuration
################################################################################

variable "openmetadata_helm_set_values" {
  description = "Generic Helm set values applied directly to the OpenMetadata chart. Key is Helm path (for example openmetadata.config.authentication.provider), value is converted to string."
  type        = map(any)
  default     = {}
}

variable "openmetadata_helm_set_sensitive_values" {
  description = "Generic sensitive Helm set values applied directly to the OpenMetadata chart via set_sensitive."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "openmetadata_external_secrets" {
  description = "Additional ExternalSecret entries keyed by Kubernetes Secret name. secret_arn is the AWS source secret, secret_key is the key written inside the Kubernetes Secret, and optional secret_property selects a JSON field from the AWS secret value."
  type = map(object({
    secret_arn      = string
    secret_key      = optional(string, "value")
    secret_property = optional(string, null)
  }))
  default = {}
}

variable "openmetadata_external_secret_kms_key_arns" {
  description = "Optional list of KMS key ARNs to allow for decrypt when synced Secrets Manager secrets use customer-managed KMS keys."
  type        = list(string)
  default     = []
}

variable "openmetadata_external_secret_store_name" {
  description = "SecretStore name used by ExternalSecret resources."
  type        = string
  default     = "aws-secrets"
}
