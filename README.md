# Terraform AWS OpenMetadata Module

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D%201.5-623CE4?logo=terraform)](https://www.terraform.io)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%3E%3D%201.6-FFDA18?logo=opentofu)](https://opentofu.org)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D%205%2C%20%3C%207-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Tests](https://img.shields.io/badge/tests-tofu%20test-623CE4)](./tests)

## Description

Reusable Terraform / OpenTofu module for deploying [OpenMetadata](https://open-metadata.org) on AWS.

OpenMetadata is an open-source data catalog and metadata governance platform. This module provisions a production-ready OpenMetadata installation backed by managed AWS services:

| AWS Service | Role |
| --- | --- |
| Amazon EKS | Kubernetes cluster running the OpenMetadata application |
| Amazon RDS (PostgreSQL) | OpenMetadata metadata store |
| Amazon OpenSearch | Full-text search and indexing |
| AWS Secrets Manager | Credential storage for RDS and OpenSearch |
| AWS KMS | Encryption at rest for all data-plane services |
| AWS ALB (via Load Balancer Controller) | Ingress / HTTP(S) access to the UI |
| Amazon Route 53 | Optional DNS record pointing to the ALB |
| AWS ACM (Private CA) | Optional TLS certificate for the ingress |

### Submodules

Each concern is separated into an independently toggle-able submodule:

| Submodule | What it creates |
| --- | --- |
| `cluster` | EKS cluster, managed node group, KMS encryption for K8s secrets |
| `addons` | AWS Load Balancer Controller and External Secrets Operator (Helm releases + IRSA) |
| `data` | RDS PostgreSQL instance, OpenSearch domain, and Secrets Manager secrets for both |
| `app` | OpenMetadata Helm release, K8s namespace, IRSA role, ALB ingress, optional TLS |
| `access` | EKS access entries for CI/CD pipelines or human operators |
| `dns` | Route 53 CNAME record pointing to the ALB |

----
## Prerequisites

Before using this module you need:

- **VPC** with at least two **private subnets** across different AZs (used by EKS, RDS, and OpenSearch).
- **KMS key** — a customer-managed key used to encrypt EKS secrets, RDS, OpenSearch, and Secrets Manager secrets.
- **IAM permissions boundary ARN** — required by the module for every IAM role it creates.
- **Approved EKS node AMI ID** — the managed node group requires an explicit AMI ID. Use `AL2023_ARM_64_STANDARD` for Graviton (`m7g.*`) instances or `AL2023_x86_64_STANDARD` for x86.
- **AWS credentials** configured locally (e.g. via `AWS_PROFILE` or environment variables).

> **Note**: If you already have an EKS cluster, RDS instance, or OpenSearch domain, you can reuse them — see [Bring Your Own Resources](#bring-your-own-resources) below.

----
## Usage

```hcl
module "openmetadata" {
  source  = "cloudandthings/open-metadata/aws"
  version = "~> 1.0"

  # Naming
  name        = "my-openmetadata"
  name_prefix = "myom"          # Short prefix — OpenSearch domain names are limited to 28 chars

  # AWS context
  region     = "us-east-1"
  account_id = "123456789012"
  tags       = { Environment = "production" }

  # Security
  iam_role_permissions_boundary = "arn:aws:iam::123456789012:policy/my-boundary"
  kms_key_id                    = "arn:aws:kms:us-east-1:123456789012:key/..."

  # Networking
  vpc_id             = "vpc-0abc1234"
  private_subnet_ids = ["subnet-0aaa", "subnet-0bbb", "subnet-0ccc"]

  # EKS
  kubernetes_version     = "1.32"
  eks_node_instance_type = "m7g.xlarge"   # Graviton — matches AL2023_ARM_64_STANDARD
  eks_node_ami_id        = "ami-0abc1234"
  eks_node_desired_size  = 2
  eks_node_min_size      = 1
  eks_node_max_size      = 4

  # Database (RDS PostgreSQL)
  database_name           = "openmetadata"
  database_username       = "openmetadata"
  rds_instance_class      = "db.t3.medium"
  rds_engine_version      = "16.3"
  rds_family              = "postgres16"
  rds_allocated_storage   = 50
  rds_multi_az            = true
  rds_deletion_protection = true
  rds_skip_final_snapshot = false

  # OpenSearch
  opensearch_engine_version  = "OpenSearch_2.17"
  opensearch_instance_type   = "m6g.large.search"
  opensearch_instance_count  = 1
  opensearch_ebs_volume_size = 50
  opensearch_master_username = "openmetadata"

  # Kubernetes namespace
  namespace = "openmetadata"
}
```

See [examples/basic/](./examples/basic/) for a complete working example.

### Bring Your Own Resources

Each major component can be disabled when you already have that resource. Supply the corresponding `existing_*` inputs in its place:

```hcl
# Use an existing EKS cluster instead of creating one
create_cluster               = false
existing_cluster_name        = "my-existing-cluster"
existing_cluster_endpoint    = "https://..."
existing_cluster_ca_data     = "..."
existing_oidc_provider_arn   = "arn:aws:iam::..."
existing_cluster_security_group_id = "sg-..."
existing_node_security_group_id    = "sg-..."

# Use an existing PostgreSQL database
create_rds                   = false
existing_database_endpoint   = "my-db.cluster-xyz.us-east-1.rds.amazonaws.com"
existing_database_secret_arn = "arn:aws:secretsmanager:..."

# Use an existing OpenSearch domain
create_opensearch              = false
existing_opensearch_endpoint   = "search-my-domain-xyz.us-east-1.es.amazonaws.com"
existing_opensearch_secret_arn = "arn:aws:secretsmanager:..."
```

### Optional DNS and TLS

```hcl
# Create a Route 53 CNAME record
route53_zone_name = "internal.example.com"
subdomain         = "openmetadata"           # resolves to openmetadata.internal.example.com

# Enable TLS via AWS Private CA
enable_tls        = true
acm_private_ca_arn = "arn:aws:acm-pca:..."
```

### Granting EKS Access

```hcl
# Give a CI/CD role full cluster admin
cluster_access_principals = {
  ci = {
    principal_arn = "arn:aws:iam::123456789012:role/my-ci-role"
  }
}

# Give a team namespace-scoped access
namespace_access_principals = {
  data-team = {
    principal_arn = "arn:aws:iam::123456789012:role/data-team-role"
    namespaces    = ["openmetadata"]
  }
}
```

----
## Notes

- **Credential flow**: RDS and OpenSearch passwords are generated randomly by Terraform, stored in AWS Secrets Manager, and synced into Kubernetes as `Secret` objects via the External Secrets Operator. OpenMetadata reads them from there at startup.
- **IRSA**: The OpenMetadata pod runs under a Kubernetes service account bound to an IAM role (IRSA) with permissions to read Glue and S3 — the minimum required for data discovery integrations.
- **ALB security group**: The ALB security group is owned by the `app` submodule rather than the `cluster` submodule because its ingress rules are tightly coupled to the `ingress_cidr_blocks` variable.
- **Encryption**: All data-plane services (EKS secrets, RDS, OpenSearch, Secrets Manager) are encrypted with the customer-managed KMS key passed via `kms_key_id`. A separate `secrets_kms_key_id` can be used for Secrets Manager if needed.
- **OpenTofu / Terraform**: The module is compatible with both. The primary development binary is `tofu` (OpenTofu ≥ 1.6). Terraform ≥ 1.5 is also supported.

----
## Known issues

None at this time.

----
## Contributing

Direct contributions are welcome.

See [`CONTRIBUTING.md`](./.github/CONTRIBUTING.md) for further information.

<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID for OpenSearch access policy rendering. | `string` | n/a | yes |
| <a name="input_acm_private_ca_arn"></a> [acm\_private\_ca\_arn](#input\_acm\_private\_ca\_arn) | Private CA ARN used to issue the OpenMetadata certificate. | `string` | `null` | no |
| <a name="input_aws_lb_controller_chart_version"></a> [aws\_lb\_controller\_chart\_version](#input\_aws\_lb\_controller\_chart\_version) | Helm chart version for the AWS Load Balancer Controller. | `string` | `"3.1.0"` | no |
| <a name="input_cluster_access_principals"></a> [cluster\_access\_principals](#input\_cluster\_access\_principals) | Keyed map of principals that should get cluster-scoped access. | <pre>map(object({<br/>    principal_arn = string<br/>    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_api_ingress_cidr_blocks"></a> [cluster\_api\_ingress\_cidr\_blocks](#input\_cluster\_api\_ingress\_cidr\_blocks) | CIDR ranges allowed to reach the private EKS API endpoint. | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> | no |
| <a name="input_create"></a> [create](#input\_create) | Global create toggle for the module. | `bool` | `true` | no |
| <a name="input_create_access"></a> [create\_access](#input\_create\_access) | Whether to manage EKS access entries. | `bool` | `true` | no |
| <a name="input_create_addons"></a> [create\_addons](#input\_create\_addons) | Whether to create cluster-wide addon resources. | `bool` | `true` | no |
| <a name="input_create_app"></a> [create\_app](#input\_create\_app) | Whether to create the OpenMetadata application resources. | `bool` | `true` | no |
| <a name="input_create_aws_load_balancer_controller"></a> [create\_aws\_load\_balancer\_controller](#input\_create\_aws\_load\_balancer\_controller) | Whether to install the AWS Load Balancer Controller addon. | `bool` | `true` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Whether to create the EKS cluster resources. | `bool` | `true` | no |
| <a name="input_create_data"></a> [create\_data](#input\_create\_data) | Whether to create OpenMetadata data-plane resources. | `bool` | `true` | no |
| <a name="input_create_external_secrets_operator"></a> [create\_external\_secrets\_operator](#input\_create\_external\_secrets\_operator) | Whether to install the External Secrets Operator addon. | `bool` | `true` | no |
| <a name="input_create_ingress"></a> [create\_ingress](#input\_create\_ingress) | Whether to create the OpenMetadata ingress resources. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the Kubernetes namespace. | `bool` | `true` | no |
| <a name="input_create_node_group"></a> [create\_node\_group](#input\_create\_node\_group) | Whether to create the default EKS managed node group. | `bool` | `true` | no |
| <a name="input_create_openmetadata_release"></a> [create\_openmetadata\_release](#input\_create\_openmetadata\_release) | Whether to install the OpenMetadata Helm release. | `bool` | `true` | no |
| <a name="input_create_opensearch"></a> [create\_opensearch](#input\_create\_opensearch) | Whether to create the OpenSearch domain. | `bool` | `true` | no |
| <a name="input_create_opensearch_secret"></a> [create\_opensearch\_secret](#input\_create\_opensearch\_secret) | Whether to create the OpenSearch credentials secret. | `bool` | `true` | no |
| <a name="input_create_rds"></a> [create\_rds](#input\_create\_rds) | Whether to create the PostgreSQL database. When false, provide existing\_database\_endpoint and existing\_database\_secret\_arn for any path that needs database connectivity. | `bool` | `true` | no |
| <a name="input_create_rds_secret"></a> [create\_rds\_secret](#input\_create\_rds\_secret) | Whether to create the RDS credentials secret when create\_rds is true. Managed RDS currently requires this to remain true. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | OpenMetadata database name. Used as the managed RDS database name when create\_rds is true. When create\_rds is false, this database must already exist on existing\_database\_endpoint. | `string` | `"openmetadata"` | no |
| <a name="input_database_secret_property"></a> [database\_secret\_property](#input\_database\_secret\_property) | Optional JSON property to extract from the database secret value. Leave null for plain string secrets. Defaults to password only when this module creates the database secret (create\_data, create\_rds, and create\_rds\_secret are all true). | `string` | `null` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | OpenMetadata database username. Used as the managed RDS username when create\_rds is true. When create\_rds is false, this user must already exist and have access to database\_name. | `string` | `"openmetadata"` | no |
| <a name="input_eks_node_ami_id"></a> [eks\_node\_ami\_id](#input\_eks\_node\_ami\_id) | Approved AMI ID for the EKS managed node group. | `string` | n/a | yes |
| <a name="input_eks_node_ami_type"></a> [eks\_node\_ami\_type](#input\_eks\_node\_ami\_type) | AMI type for the EKS managed node group. | `string` | `"AL2023_ARM_64_STANDARD"` | no |
| <a name="input_eks_node_desired_size"></a> [eks\_node\_desired\_size](#input\_eks\_node\_desired\_size) | Desired node count for the default EKS managed node group. | `number` | `2` | no |
| <a name="input_eks_node_iam_role_policy_json"></a> [eks\_node\_iam\_role\_policy\_json](#input\_eks\_node\_iam\_role\_policy\_json) | Optional JSON IAM policy document to attach to the default node role. | `string` | `null` | no |
| <a name="input_eks_node_instance_type"></a> [eks\_node\_instance\_type](#input\_eks\_node\_instance\_type) | Instance type for the default EKS managed node group. | `string` | `"m7g.large"` | no |
| <a name="input_eks_node_max_size"></a> [eks\_node\_max\_size](#input\_eks\_node\_max\_size) | Maximum node count for the default EKS managed node group. | `number` | `4` | no |
| <a name="input_eks_node_min_size"></a> [eks\_node\_min\_size](#input\_eks\_node\_min\_size) | Minimum node count for the default EKS managed node group. | `number` | `1` | no |
| <a name="input_eks_node_startup_script"></a> [eks\_node\_startup\_script](#input\_eks\_node\_startup\_script) | Optional shell script to run on EKS node startup. | `string` | `null` | no |
| <a name="input_enable_tls"></a> [enable\_tls](#input\_enable\_tls) | Whether to enable TLS for the OpenMetadata ingress. | `bool` | `false` | no |
| <a name="input_existing_cluster_ca_data"></a> [existing\_cluster\_ca\_data](#input\_existing\_cluster\_ca\_data) | Existing cluster certificate authority data used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_cluster_endpoint"></a> [existing\_cluster\_endpoint](#input\_existing\_cluster\_endpoint) | Existing cluster API endpoint used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_cluster_name"></a> [existing\_cluster\_name](#input\_existing\_cluster\_name) | Existing cluster name used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_cluster_security_group_id"></a> [existing\_cluster\_security\_group\_id](#input\_existing\_cluster\_security\_group\_id) | Existing cluster security group ID used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_database_endpoint"></a> [existing\_database\_endpoint](#input\_existing\_database\_endpoint) | Endpoint (host or host:port) of an existing PostgreSQL database. Required when create\_rds is false and managed data resources are used, and also required when create\_data is false while create\_app and create\_openmetadata\_release are true. | `string` | `null` | no |
| <a name="input_existing_database_secret_arn"></a> [existing\_database\_secret\_arn](#input\_existing\_database\_secret\_arn) | Secrets Manager ARN for the existing database password (or JSON field selected by database\_secret\_property). Required in existing-database mode whenever the OpenMetadata release needs database credentials. | `string` | `null` | no |
| <a name="input_existing_node_security_group_id"></a> [existing\_node\_security\_group\_id](#input\_existing\_node\_security\_group\_id) | Existing node security group ID used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_oidc_provider_arn"></a> [existing\_oidc\_provider\_arn](#input\_existing\_oidc\_provider\_arn) | Existing OIDC provider ARN used when create\_cluster is false. | `string` | `null` | no |
| <a name="input_existing_opensearch_endpoint"></a> [existing\_opensearch\_endpoint](#input\_existing\_opensearch\_endpoint) | Existing OpenSearch endpoint used when create\_opensearch is false. Also required when create\_data is false while create\_app and create\_openmetadata\_release are true. | `string` | `null` | no |
| <a name="input_existing_opensearch_secret_arn"></a> [existing\_opensearch\_secret\_arn](#input\_existing\_opensearch\_secret\_arn) | Secrets Manager ARN for the existing OpenSearch password (or JSON field selected by opensearch\_secret\_property). Required in existing-OpenSearch mode whenever the OpenMetadata release needs OpenSearch credentials. | `string` | `null` | no |
| <a name="input_external_secrets_chart_version"></a> [external\_secrets\_chart\_version](#input\_external\_secrets\_chart\_version) | Helm chart version for the External Secrets Operator. | `string` | `"2.2.0"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role. If not specified then the default of '/' is used. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary ARN for IAM roles created by this module. | `string` | n/a | yes |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | CIDR ranges allowed inbound to the OpenMetadata ALB. | `list(string)` | `[]` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID or ARN used for data-plane encryption (EKS, RDS, OpenSearch). | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the EKS cluster. | `string` | `"1.35"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name prefix used for named resources. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Short prefix for resources with stricter name limits (e.g. OpenSearch 28-char domain limit). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for OpenMetadata. | `string` | `"openmetadata"` | no |
| <a name="input_namespace_access_principals"></a> [namespace\_access\_principals](#input\_namespace\_access\_principals) | Keyed map of principals that should get namespace-scoped access. | <pre>map(object({<br/>    principal_arn = string<br/>    namespaces    = list(string)<br/>    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy")<br/>  }))</pre> | `{}` | no |
| <a name="input_oidc_thumbprints"></a> [oidc\_thumbprints](#input\_oidc\_thumbprints) | Custom OIDC root CA thumbprints for the EKS module. This module configures include\_oidc\_root\_ca\_thumbprint = false, so supply any required root CA thumbprints here. | `list(string)` | `[]` | no |
| <a name="input_openmetadata_chart_version"></a> [openmetadata\_chart\_version](#input\_openmetadata\_chart\_version) | OpenMetadata Helm chart version. | `string` | `"1.12.3"` | no |
| <a name="input_openmetadata_external_secret_kms_key_arns"></a> [openmetadata\_external\_secret\_kms\_key\_arns](#input\_openmetadata\_external\_secret\_kms\_key\_arns) | Optional list of KMS key ARNs to allow decrypt for synced Secrets Manager values when customer-managed KMS keys are used. | `list(string)` | `[]` | no |
| <a name="input_openmetadata_external_secret_store_name"></a> [openmetadata\_external\_secret\_store\_name](#input\_openmetadata\_external\_secret\_store\_name) | SecretStore name used by ExternalSecret resources. | `string` | `"aws-secrets"` | no |
| <a name="input_openmetadata_external_secrets"></a> [openmetadata\_external\_secrets](#input\_openmetadata\_external\_secrets) | Additional ExternalSecret entries keyed by Kubernetes Secret name. secret\_arn is the AWS source secret, secret\_key is the key written inside the Kubernetes Secret, and optional secret\_property selects a JSON field from the AWS secret value. | <pre>map(object({<br/>    secret_arn      = string<br/>    secret_key      = optional(string, "value")<br/>    secret_property = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_openmetadata_fqdn"></a> [openmetadata\_fqdn](#input\_openmetadata\_fqdn) | Precomputed OpenMetadata FQDN used for ACM and Route53 resources. | `string` | `null` | no |
| <a name="input_openmetadata_heap_opts"></a> [openmetadata\_heap\_opts](#input\_openmetadata\_heap\_opts) | JVM heap options passed to OpenMetadata via OPENMETADATA\_HEAP\_OPTS. | `string` | `"-Xmx2G -Xms2G"` | no |
| <a name="input_openmetadata_helm_set_sensitive_values"></a> [openmetadata\_helm\_set\_sensitive\_values](#input\_openmetadata\_helm\_set\_sensitive\_values) | Generic sensitive Helm set values applied directly to the OpenMetadata chart via set\_sensitive. | `map(string)` | `{}` | no |
| <a name="input_openmetadata_helm_set_values"></a> [openmetadata\_helm\_set\_values](#input\_openmetadata\_helm\_set\_values) | Generic Helm set values applied directly to the OpenMetadata chart. Key is Helm path (for example openmetadata.config.authentication.provider), value is converted to string. | `map(any)` | `{}` | no |
| <a name="input_opensearch_ebs_volume_size"></a> [opensearch\_ebs\_volume\_size](#input\_opensearch\_ebs\_volume\_size) | OpenSearch EBS volume size in GB. | `number` | `20` | no |
| <a name="input_opensearch_engine_version"></a> [opensearch\_engine\_version](#input\_opensearch\_engine\_version) | OpenSearch engine version. | `string` | `"OpenSearch_3.3"` | no |
| <a name="input_opensearch_instance_count"></a> [opensearch\_instance\_count](#input\_opensearch\_instance\_count) | OpenSearch data node count. | `number` | `2` | no |
| <a name="input_opensearch_instance_type"></a> [opensearch\_instance\_type](#input\_opensearch\_instance\_type) | OpenSearch node instance type. | `string` | `"m6g.large.search"` | no |
| <a name="input_opensearch_master_username"></a> [opensearch\_master\_username](#input\_opensearch\_master\_username) | OpenSearch master username. | `string` | `"openmetadata"` | no |
| <a name="input_opensearch_secret_property"></a> [opensearch\_secret\_property](#input\_opensearch\_secret\_property) | Optional JSON property to extract from the OpenSearch secret value. Leave null for plain string secrets. Defaults to password only when this module creates the OpenSearch secret (create\_data, create\_opensearch, and create\_opensearch\_secret are all true). | `string` | `null` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs used by EKS and data-plane services. | `list(string)` | n/a | yes |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | Allocated RDS storage in GB to create. | `number` | `20` | no |
| <a name="input_rds_backup_retention_period"></a> [rds\_backup\_retention\_period](#input\_rds\_backup\_retention\_period) | Number of days to retain RDS automated backups for the created RDS. Set to 0 to disable backups. | `number` | `7` | no |
| <a name="input_rds_deletion_protection"></a> [rds\_deletion\_protection](#input\_rds\_deletion\_protection) | Whether to enable RDS deletion protection on the created RDS. | `bool` | n/a | yes |
| <a name="input_rds_engine_version"></a> [rds\_engine\_version](#input\_rds\_engine\_version) | PostgreSQL engine version to create. | `string` | `"18.3"` | no |
| <a name="input_rds_family"></a> [rds\_family](#input\_rds\_family) | Parameter group family for PostgreSQL to create. | `string` | `"postgres18"` | no |
| <a name="input_rds_ingress_cidr_blocks"></a> [rds\_ingress\_cidr\_blocks](#input\_rds\_ingress\_cidr\_blocks) | Additional CIDR blocks allowed to reach the RDS instance on port 5432. Useful for direct database access from a bastion or developer machine. | `list(string)` | `[]` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | RDS instance class to create. | `string` | `"db.t3.medium"` | no |
| <a name="input_rds_multi_az"></a> [rds\_multi\_az](#input\_rds\_multi\_az) | Whether to enable Multi-AZ on the created RDS. | `bool` | n/a | yes |
| <a name="input_rds_skip_final_snapshot"></a> [rds\_skip\_final\_snapshot](#input\_rds\_skip\_final\_snapshot) | Whether to skip the final snapshot on RDS deletion. | `bool` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the deployment. | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Private Route53 hosted zone used for the OpenMetadata record. | `string` | `null` | no |
| <a name="input_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#input\_secrets\_kms\_key\_id) | KMS key ID or ARN used to encrypt AWS Secrets Manager secrets. | `string` | `null` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain used for the OpenMetadata DNS name. | `string` | `"open-metadata"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to supported resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used by the cluster and data plane. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access"></a> [access](#module\_access) | ./modules/access | n/a |
| <a name="module_addons"></a> [addons](#module\_addons) | ./modules/addons | n/a |
| <a name="module_app"></a> [app](#module\_app) | ./modules/app | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_data"></a> [data](#module\_data) | ./modules/data | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ./modules/dns | n/a |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entry_ids"></a> [access\_entry\_ids](#output\_access\_entry\_ids) | IDs of EKS access resources created for the cluster. |
| <a name="output_cluster_ca_data"></a> [cluster\_ca\_data](#output\_cluster\_ca\_data) | Base64-encoded certificate authority data for the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for the EKS cluster API server. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Cluster security group ID for the EKS cluster. |
| <a name="output_database_endpoint"></a> [database\_endpoint](#output\_database\_endpoint) | Endpoint for the PostgreSQL database instance. |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | Node security group ID for the EKS managed node group. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN used for IRSA. |
| <a name="output_openmetadata_alb_dns"></a> [openmetadata\_alb\_dns](#output\_openmetadata\_alb\_dns) | DNS name of the ALB provisioned for OpenMetadata. |
| <a name="output_openmetadata_fqdn"></a> [openmetadata\_fqdn](#output\_openmetadata\_fqdn) | Route53 record FQDN pointing to the OpenMetadata ALB. |
| <a name="output_openmetadata_irsa_role_arn"></a> [openmetadata\_irsa\_role\_arn](#output\_openmetadata\_irsa\_role\_arn) | IAM role ARN for the OpenMetadata service account. |
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | Endpoint for the OpenSearch domain. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5, < 7 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5, < 7 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.35 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

----
### Resources

| Name | Type |
|------|------|
| [aws_kms_key.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

----
<!-- END_TF_DOCS -->
