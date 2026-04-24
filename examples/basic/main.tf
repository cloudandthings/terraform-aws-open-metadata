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
  eks_node_ami_id = var.eks_node_ami_id

  # RDS
  rds_multi_az            = false
  rds_skip_final_snapshot = true
  rds_deletion_protection = false
}
