locals {
  create_cluster_module = var.create && var.create_cluster
  create_addons_module  = var.create && var.create_addons
  create_data_module    = var.create && var.create_data
  create_app_module     = var.create && var.create_app
  create_access_module  = var.create && var.create_access

  cluster_name              = local.create_cluster_module ? module.cluster[0].cluster_name : var.existing_cluster_name
  cluster_endpoint          = local.create_cluster_module ? module.cluster[0].cluster_endpoint : var.existing_cluster_endpoint
  cluster_ca_data           = local.create_cluster_module ? module.cluster[0].cluster_ca_data : var.existing_cluster_ca_data
  cluster_security_group_id = local.create_cluster_module ? module.cluster[0].cluster_security_group_id : var.existing_cluster_security_group_id
  node_security_group_id    = local.create_cluster_module ? module.cluster[0].node_security_group_id : var.existing_node_security_group_id
  oidc_provider_arn         = local.create_cluster_module ? module.cluster[0].oidc_provider_arn : var.existing_oidc_provider_arn

  database_endpoint        = local.create_data_module ? module.data[0].rds_endpoint : var.existing_database_endpoint
  database_endpoint_host   = try(regex("^[^:]+", local.database_endpoint)[0], local.database_endpoint)
  database_host            = local.create_data_module ? module.data[0].rds_host : local.database_endpoint_host
  database_secret_arn      = local.create_data_module ? module.data[0].rds_secret_arn : var.existing_database_secret_arn
  database_secret_property = (local.create_data_module && var.create_rds && var.create_rds_secret) ? coalesce(var.database_secret_property, "password") : var.database_secret_property

  opensearch_endpoint        = local.create_data_module ? module.data[0].opensearch_endpoint : var.existing_opensearch_endpoint
  opensearch_secret_arn      = local.create_data_module ? module.data[0].opensearch_secret_arn : var.existing_opensearch_secret_arn
  opensearch_secret_property = (local.create_data_module && var.create_opensearch && var.create_opensearch_secret) ? coalesce(var.opensearch_secret_property, "password") : var.opensearch_secret_property

  # Rationalized KMS behavior for ESO/IRSA decrypt permissions:
  # - Automatically include secrets_kms_key used by managed Secrets Manager secrets.
  # - Keep openmetadata_external_secret_kms_key_arns for additional customer-managed keys.
  secrets_kms_key_arn = try(data.aws_kms_key.secrets[0].arn, null)

  effective_external_secret_kms_key_arns = distinct(concat(
    (local.secrets_kms_key_arn == null
      ? []
      : [local.secrets_kms_key_arn]
    ),
    var.openmetadata_external_secret_kms_key_arns
  ))
}

check "existing_cluster_inputs" {
  assert {
    condition = (
      var.create_cluster || !(var.create_addons || var.create_app || var.create_access)
      ) || (
      var.existing_cluster_name != null &&
      var.existing_cluster_endpoint != null &&
      var.existing_cluster_ca_data != null
    )
    error_message = "When create_cluster is false and cluster-connected modules are enabled, existing_cluster_name, existing_cluster_endpoint, and existing_cluster_ca_data must be provided."
  }
}

check "existing_cluster_iam_inputs" {
  assert {
    condition = (
      var.create_cluster || !(var.create_addons || var.create_app)
    ) || var.existing_oidc_provider_arn != null
    error_message = "When create_cluster is false and addons or app are enabled, existing_oidc_provider_arn must be provided."
  }
}

check "existing_cluster_network_inputs" {
  assert {
    condition = (
      var.create_cluster || !(var.create_data || var.create_app)
    ) || var.existing_node_security_group_id != null
    error_message = "When create_cluster is false and data or app are enabled, existing_node_security_group_id must be provided."
  }
}

check "existing_data_inputs" {
  assert {
    condition = (
      var.create_data || !var.create_app || !var.create_openmetadata_release
      ) || (
      var.existing_database_endpoint != null &&
      var.existing_database_secret_arn != null &&
      var.existing_opensearch_endpoint != null &&
      var.existing_opensearch_secret_arn != null
    )
    error_message = "When create_data is false and the OpenMetadata release is enabled, existing_database_endpoint, existing_database_secret_arn, existing_opensearch_endpoint, and existing_opensearch_secret_arn must be provided."
  }
}

provider "kubernetes" {
  host                   = coalesce(local.cluster_endpoint, "https://example.invalid")
  cluster_ca_certificate = local.cluster_ca_data == null ? "" : base64decode(local.cluster_ca_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", coalesce(local.cluster_name, "placeholder"), "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = coalesce(local.cluster_endpoint, "https://example.invalid")
    cluster_ca_certificate = local.cluster_ca_data == null ? "" : base64decode(local.cluster_ca_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", coalesce(local.cluster_name, "placeholder"), "--region", var.region]
    }
  }
}

module "cluster" {
  count = local.create_cluster_module ? 1 : 0

  source = "./modules/cluster"

  create            = true
  create_node_group = var.create_node_group

  name = var.name

  vpc_id                          = var.vpc_id
  private_subnet_ids              = var.private_subnet_ids
  cluster_api_ingress_cidr_blocks = var.cluster_api_ingress_cidr_blocks

  kubernetes_version = var.kubernetes_version

  eks_node_instance_type  = var.eks_node_instance_type
  eks_node_desired_size   = var.eks_node_desired_size
  eks_node_min_size       = var.eks_node_min_size
  eks_node_max_size       = var.eks_node_max_size
  eks_node_ami_id         = var.eks_node_ami_id
  eks_node_ami_type       = var.eks_node_ami_type
  eks_node_startup_script = var.eks_node_startup_script

  oidc_thumbprints              = var.oidc_thumbprints
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_path                 = var.iam_role_path
  eks_node_iam_role_policy_json = var.eks_node_iam_role_policy_json

  kms_key_id = var.kms_key_id

  tags = var.tags
}

module "access" {
  count = local.create_access_module ? 1 : 0

  source = "./modules/access"

  create                      = true
  cluster_name                = local.cluster_name
  cluster_access_principals   = var.cluster_access_principals
  namespace_access_principals = var.namespace_access_principals

  depends_on = [module.cluster]
}

module "addons" {
  count = local.create_addons_module ? 1 : 0

  source = "./modules/addons"

  create                              = true
  create_aws_load_balancer_controller = var.create_aws_load_balancer_controller
  create_external_secrets_operator    = var.create_external_secrets_operator
  cluster_name                        = local.cluster_name
  oidc_provider_arn                   = local.oidc_provider_arn
  name_prefix                         = var.name_prefix
  iam_role_permissions_boundary       = var.iam_role_permissions_boundary
  iam_role_path                       = var.iam_role_path
  aws_lb_controller_chart_version     = var.aws_lb_controller_chart_version
  external_secrets_chart_version      = var.external_secrets_chart_version
  region                              = var.region
  vpc_id                              = var.vpc_id

  # The Helm provider role only gets
  # cluster access once module.access creates the EKS access entry, so addons
  # must not start until the access entry (and its policy association) exist.
  depends_on = [module.access]
}

module "data" {
  count = local.create_data_module ? 1 : 0

  source = "./modules/data"

  create                         = true
  create_rds                     = var.create_rds
  create_rds_secret              = var.create_rds_secret
  create_opensearch              = var.create_opensearch
  create_opensearch_secret       = var.create_opensearch_secret
  name                           = var.name
  name_prefix                    = var.name_prefix
  vpc_id                         = var.vpc_id
  private_subnet_ids             = var.private_subnet_ids
  node_security_group_id         = local.node_security_group_id
  kms_key_id                     = var.kms_key_id
  secrets_kms_key_id             = var.secrets_kms_key_id
  region                         = var.region
  account_id                     = var.account_id
  rds_instance_class             = var.rds_instance_class
  rds_engine_version             = var.rds_engine_version
  rds_family                     = var.rds_family
  rds_allocated_storage          = var.rds_allocated_storage
  database_name                  = var.database_name
  database_username              = var.database_username
  rds_multi_az                   = var.rds_multi_az
  rds_skip_final_snapshot        = var.rds_skip_final_snapshot
  rds_deletion_protection        = var.rds_deletion_protection
  rds_backup_retention_period    = var.rds_backup_retention_period
  rds_ingress_cidr_blocks        = var.rds_ingress_cidr_blocks
  opensearch_engine_version      = var.opensearch_engine_version
  opensearch_instance_type       = var.opensearch_instance_type
  opensearch_instance_count      = var.opensearch_instance_count
  opensearch_ebs_volume_size     = var.opensearch_ebs_volume_size
  opensearch_master_username     = var.opensearch_master_username
  existing_rds_endpoint          = var.existing_database_endpoint
  existing_rds_secret_arn        = var.existing_database_secret_arn
  existing_opensearch_endpoint   = var.existing_opensearch_endpoint
  existing_opensearch_secret_arn = var.existing_opensearch_secret_arn
}

module "app" {
  count = local.create_app_module ? 1 : 0

  source = "./modules/app"

  create                        = true
  create_namespace              = var.create_namespace
  create_openmetadata_release   = var.create_openmetadata_release
  create_ingress                = var.create_ingress
  name                          = var.name
  name_prefix                   = var.name_prefix
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_path                 = var.iam_role_path
  tags                          = var.tags
  vpc_id                        = var.vpc_id
  private_subnet_ids            = var.private_subnet_ids
  ingress_cidr_blocks           = var.ingress_cidr_blocks
  namespace                     = var.namespace
  region                        = var.region
  database_host                 = local.database_host
  database_name                 = var.database_name
  database_username             = var.database_username
  database_secret_arn           = local.database_secret_arn
  database_secret_property      = local.database_secret_property
  opensearch_endpoint           = local.opensearch_endpoint
  opensearch_master_username    = var.opensearch_master_username
  opensearch_secret_arn         = local.opensearch_secret_arn
  opensearch_secret_property    = local.opensearch_secret_property
  oidc_provider_arn             = local.oidc_provider_arn
  node_security_group_id        = local.node_security_group_id
  enable_tls                    = var.enable_tls
  acm_private_ca_arn            = var.acm_private_ca_arn

  openmetadata_fqdn      = var.openmetadata_fqdn
  openmetadata_heap_opts = var.openmetadata_heap_opts

  # Generic OpenMetadata chart configuration and optional ExternalSecrets.
  openmetadata_chart_version                = var.openmetadata_chart_version
  openmetadata_helm_set_values              = var.openmetadata_helm_set_values
  openmetadata_helm_set_sensitive_values    = var.openmetadata_helm_set_sensitive_values
  openmetadata_external_secrets             = var.openmetadata_external_secrets
  openmetadata_external_secret_kms_key_arns = local.effective_external_secret_kms_key_arns
  openmetadata_external_secret_store_name   = var.openmetadata_external_secret_store_name

  depends_on = [module.addons]
}

module "dns" {
  count = local.create_app_module && var.route53_zone_name != null ? 1 : 0

  source = "./modules/dns"

  create            = true
  route53_zone_name = var.route53_zone_name
  vpc_id            = var.vpc_id
  subdomain         = var.subdomain
  ingress_hostname  = try(module.app[0].ingress_hostname, null)
}
