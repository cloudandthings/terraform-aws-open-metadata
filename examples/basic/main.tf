#--------------------------------------------------------------------------------------
# Naming
#--------------------------------------------------------------------------------------

# Generate unique naming for resources
resource "random_integer" "naming" {
  min = 100000
  max = 999999
}

locals {
  naming_prefix = "example-basic-${random_integer.naming.id}"
  short_prefix  = "eb${random_integer.naming.id}"
}

#--------------------------------------------------------------------------------------
# Supporting resources
#--------------------------------------------------------------------------------------

# None

#--------------------------------------------------------------------------------------
# Example
#--------------------------------------------------------------------------------------

module "example" {
  # Uncomment and update as needed
  # source  = "<your_module_url>"
  # version = "~> 1.0"
  source = "../../"

  # Naming
  name        = local.naming_prefix
  name_prefix = local.short_prefix

  # AWS Context
  region     = var.region
  account_id = var.account_id
  tags       = {}

  # Security
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  kms_key_id                    = var.kms_key_id

  # Networking
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  # EKS
  kubernetes_version     = "1.32"
  eks_node_instance_type = "m7g.xlarge"
  eks_node_desired_size  = 2
  eks_node_min_size      = 1
  eks_node_max_size      = 4
  eks_node_ami_id        = var.eks_node_ami_id

  # Database
  database_name     = "openmetadata"
  database_username = "openmetadata"

  # RDS
  rds_instance_class      = "db.t3.medium"
  rds_engine_version      = "16.3"
  rds_family              = "postgres16"
  rds_allocated_storage   = 20
  rds_multi_az            = false
  rds_skip_final_snapshot = true
  rds_deletion_protection = false

  # OpenSearch
  opensearch_engine_version  = "OpenSearch_2.17"
  opensearch_instance_type   = "t3.small.search"
  opensearch_instance_count  = 1
  opensearch_ebs_volume_size = 20
  opensearch_master_username = "openmetadata"

  # App
  namespace = "openmetadata"
}
