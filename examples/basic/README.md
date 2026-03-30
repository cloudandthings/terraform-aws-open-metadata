<!-- BEGIN_TF_DOCS -->
----
## main.tf
```hcl
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
```
----

## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS profile | `string` | `null` | no |
| <a name="input_eks_node_ami_id"></a> [eks\_node\_ami\_id](#input\_eks\_node\_ami\_id) | AMI ID for the EKS managed node group | `string` | n/a | yes |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary ARN for IAM roles | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID or ARN for data-plane encryption | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs for EKS and data-plane services | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the deployment | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the cluster and data plane | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example"></a> [example](#module\_example) | ../../ | n/a |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_example"></a> [module\_example](#output\_module\_example) | module.example |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5, < 7 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

----
### Resources

| Name | Type |
|------|------|
| [random_integer.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

----
<!-- END_TF_DOCS -->
