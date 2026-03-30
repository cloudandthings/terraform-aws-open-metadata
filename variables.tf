################################################################################
# Core Controls
################################################################################

variable "create" {
  description = "Global create toggle for the module."
  type        = bool
  default     = true
}

variable "create_cluster" {
  description = "Whether to create the EKS cluster resources."
  type        = bool
  default     = true
}

variable "create_node_group" {
  description = "Whether to create the default EKS managed node group."
  type        = bool
  default     = true
}

variable "create_addons" {
  description = "Whether to create cluster-wide addon resources."
  type        = bool
  default     = true
}

variable "create_aws_load_balancer_controller" {
  description = "Whether to install the AWS Load Balancer Controller addon."
  type        = bool
  default     = true
}

variable "create_external_secrets_operator" {
  description = "Whether to install the External Secrets Operator addon."
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

variable "create_data" {
  description = "Whether to create OpenMetadata data-plane resources."
  type        = bool
  default     = true
}

variable "create_rds" {
  description = "Whether to create the PostgreSQL database. When false, provide existing_database_endpoint and existing_database_secret_arn for any path that needs database connectivity."
  type        = bool
  default     = true
}

variable "create_rds_secret" {
  description = "Whether to create the RDS credentials secret when create_rds is true. Managed RDS currently requires this to remain true."
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

variable "create_app" {
  description = "Whether to create the OpenMetadata application resources."
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
  description = "Whether to create the OpenMetadata ingress resources."
  type        = bool
  default     = true
}

variable "create_access" {
  description = "Whether to manage EKS access entries."
  type        = bool
  default     = true
}

################################################################################
# AWS Context, Naming, And Tags
################################################################################

variable "region" {
  description = "AWS region for the deployment."
  type        = string
}

variable "account_id" {
  description = "AWS account ID for OpenSearch access policy rendering."
  type        = string
}

variable "name" {
  description = "Base name prefix used for named resources."
  type        = string
}

variable "name_prefix" {
  description = "Short prefix for resources with stricter name limits (e.g. OpenSearch 28-char domain limit)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to supported resources."
  type        = map(string)
}

################################################################################
# Security
################################################################################

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN for IAM roles created by this module."
  type        = string
}

variable "iam_role_path" {
  description = "Path of the IAM role. If not specified then the default of '/' is used."
  type        = string
  default     = "/"
}

variable "kms_key_id" {
  description = "KMS key ID or ARN used for data-plane encryption (EKS, RDS, OpenSearch)."
  type        = string
}

variable "secrets_kms_key_id" {
  description = "KMS key ID or ARN used to encrypt AWS Secrets Manager secrets."
  type        = string
  default     = null
}

################################################################################
# Networking And Ingress
################################################################################

variable "vpc_id" {
  description = "VPC ID used by the cluster and data plane."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by EKS and data-plane services."
  type        = list(string)
}

variable "ingress_cidr_blocks" {
  description = "CIDR ranges allowed inbound to the OpenMetadata ALB."
  type        = list(string)
  default     = []
}

variable "cluster_api_ingress_cidr_blocks" {
  description = "CIDR ranges allowed to reach the private EKS API endpoint."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "route53_zone_name" {
  description = "Private Route53 hosted zone used for the OpenMetadata record."
  type        = string
  default     = null
}

variable "subdomain" {
  description = "Subdomain used for the OpenMetadata DNS name."
  type        = string
  default     = "open-metadata"
}

variable "enable_tls" {
  description = "Whether to enable TLS for the OpenMetadata ingress."
  type        = bool
  default     = false
}

variable "acm_private_ca_arn" {
  description = "Private CA ARN used to issue the OpenMetadata certificate."
  type        = string
  default     = null
}

variable "openmetadata_fqdn" {
  description = "Precomputed OpenMetadata FQDN used for ACM and Route53 resources."
  type        = string
  default     = null
}

################################################################################
# EKS
################################################################################

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "eks_node_instance_type" {
  description = "Instance type for the default EKS managed node group."
  type        = string
}

variable "eks_node_desired_size" {
  description = "Desired node count for the default EKS managed node group."
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum node count for the default EKS managed node group."
  type        = number
}

variable "eks_node_max_size" {
  description = "Maximum node count for the default EKS managed node group."
  type        = number
}

variable "eks_node_ami_id" {
  description = "Approved AMI ID for the EKS managed node group."
  type        = string
}

variable "eks_node_ami_type" {
  description = "AMI type for the EKS managed node group."
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
}

variable "oidc_thumbprints" {
  description = "Custom OIDC root CA thumbprints for the EKS module. This module configures include_oidc_root_ca_thumbprint = false, so supply any required root CA thumbprints here."
  type        = list(string)
  default     = []
}

################################################################################
# Access
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


################################################################################
# Data Plane: Database
################################################################################
# Applies to both the managed RDS created by this module and any existing database when create_rds is false.

variable "database_name" {
  description = "OpenMetadata database name. Used as the managed RDS database name when create_rds is true. When create_rds is false, this database must already exist on existing_database_endpoint."
  type        = string
}

variable "database_username" {
  description = "OpenMetadata database username. Used as the managed RDS username when create_rds is true. When create_rds is false, this user must already exist and have access to database_name."
  type        = string
}

################################################################################
# Data Plane: RDS
################################################################################

variable "rds_instance_class" {
  description = "RDS instance class to create."
  type        = string
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version to create."
  type        = string
}

variable "rds_family" {
  description = "Parameter group family for PostgreSQL to create."
  type        = string
}

variable "rds_allocated_storage" {
  description = "Allocated RDS storage in GB to create."
  type        = number
}

variable "rds_multi_az" {
  description = "Whether to enable Multi-AZ on the created RDS."
  type        = bool
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final snapshot on RDS deletion."
  type        = bool
}

variable "rds_deletion_protection" {
  description = "Whether to enable RDS deletion protection on the created RDS."
  type        = bool
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS automated backups for the created RDS. Set to 0 to disable backups."
  type        = number
  default     = 7
}

variable "rds_ingress_cidr_blocks" {
  description = "Additional CIDR blocks allowed to reach the RDS instance on port 5432. Useful for direct database access from a bastion or developer machine."
  type        = list(string)
  default     = []
}

################################################################################
# Data Plane: OpenSearch
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
# App
################################################################################

variable "openmetadata_chart_version" {
  description = "OpenMetadata Helm chart version."
  type        = string
  default     = "1.12.3"
}

variable "openmetadata_heap_opts" {
  description = "JVM heap options passed to OpenMetadata via OPENMETADATA_HEAP_OPTS."
  type        = string
  default     = "-Xmx2G -Xms2G"
}

variable "namespace" {
  description = "Kubernetes namespace for OpenMetadata."
  type        = string
}

################################################################################
# Existing Resource Overrides
################################################################################

variable "existing_cluster_name" {
  description = "Existing cluster name used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_cluster_endpoint" {
  description = "Existing cluster API endpoint used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_cluster_ca_data" {
  description = "Existing cluster certificate authority data used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_cluster_security_group_id" {
  description = "Existing cluster security group ID used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_node_security_group_id" {
  description = "Existing node security group ID used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_oidc_provider_arn" {
  description = "Existing OIDC provider ARN used when create_cluster is false."
  type        = string
  default     = null
}

variable "existing_database_endpoint" {
  description = "Endpoint (host or host:port) of an existing PostgreSQL database. Required when create_rds is false and managed data resources are used, and also required when create_data is false while create_app and create_openmetadata_release are true."
  type        = string
  default     = null
}

variable "existing_database_secret_arn" {
  description = "Secrets Manager ARN for the existing database password (or JSON field selected by database_secret_property). Required in existing-database mode whenever the OpenMetadata release needs database credentials."
  type        = string
  default     = null
}

variable "database_secret_property" {
  description = "Optional JSON property to extract from the database secret value. Leave null for plain string secrets. Defaults to password only when this module creates the database secret (create_data, create_rds, and create_rds_secret are all true)."
  type        = string
  default     = null
}

variable "existing_opensearch_endpoint" {
  description = "Existing OpenSearch endpoint used when create_opensearch is false. Also required when create_data is false while create_app and create_openmetadata_release are true."
  type        = string
  default     = null
}

variable "existing_opensearch_secret_arn" {
  description = "Secrets Manager ARN for the existing OpenSearch password (or JSON field selected by opensearch_secret_property). Required in existing-OpenSearch mode whenever the OpenMetadata release needs OpenSearch credentials."
  type        = string
  default     = null
}

variable "opensearch_secret_property" {
  description = "Optional JSON property to extract from the OpenSearch secret value. Leave null for plain string secrets. Defaults to password only when this module creates the OpenSearch secret (create_data, create_opensearch, and create_opensearch_secret are all true)."
  type        = string
  default     = null
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
  description = "Optional list of KMS key ARNs to allow decrypt for synced Secrets Manager values when customer-managed KMS keys are used."
  type        = list(string)
  default     = []
}

variable "openmetadata_external_secret_store_name" {
  description = "SecretStore name used by ExternalSecret resources."
  type        = string
  default     = "aws-secrets"
}
