<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID used in the OpenSearch access policy. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create data-plane resources. | `bool` | `true` | no |
| <a name="input_create_opensearch"></a> [create\_opensearch](#input\_create\_opensearch) | Whether to create the OpenSearch domain. | `bool` | `true` | no |
| <a name="input_create_opensearch_secret"></a> [create\_opensearch\_secret](#input\_create\_opensearch\_secret) | Whether to create the OpenSearch credentials secret. | `bool` | `true` | no |
| <a name="input_create_rds"></a> [create\_rds](#input\_create\_rds) | Whether to create the PostgreSQL database. | `bool` | `true` | no |
| <a name="input_create_rds_secret"></a> [create\_rds\_secret](#input\_create\_rds\_secret) | Whether to create the RDS credentials secret. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name for OpenMetadata. | `string` | n/a | yes |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Master username for RDS. | `string` | n/a | yes |
| <a name="input_existing_opensearch_endpoint"></a> [existing\_opensearch\_endpoint](#input\_existing\_opensearch\_endpoint) | Existing OpenSearch endpoint used when create\_opensearch is false. | `string` | `null` | no |
| <a name="input_existing_opensearch_secret_arn"></a> [existing\_opensearch\_secret\_arn](#input\_existing\_opensearch\_secret\_arn) | Existing OpenSearch secret ARN used when create\_opensearch is false. | `string` | `null` | no |
| <a name="input_existing_rds_endpoint"></a> [existing\_rds\_endpoint](#input\_existing\_rds\_endpoint) | Existing RDS host or endpoint used when create\_rds is false. | `string` | `null` | no |
| <a name="input_existing_rds_secret_arn"></a> [existing\_rds\_secret\_arn](#input\_existing\_rds\_secret\_arn) | Existing RDS secret ARN used when create\_rds is false. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key used for encryption at rest. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name prefix for data-plane resources. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Short prefix for OpenSearch naming. | `string` | n/a | yes |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | Node security group ID allowed to reach the data plane. | `string` | `null` | no |
| <a name="input_opensearch_ebs_volume_size"></a> [opensearch\_ebs\_volume\_size](#input\_opensearch\_ebs\_volume\_size) | OpenSearch EBS volume size in GB. | `number` | n/a | yes |
| <a name="input_opensearch_engine_version"></a> [opensearch\_engine\_version](#input\_opensearch\_engine\_version) | OpenSearch engine version. | `string` | n/a | yes |
| <a name="input_opensearch_instance_count"></a> [opensearch\_instance\_count](#input\_opensearch\_instance\_count) | OpenSearch data node count. | `number` | n/a | yes |
| <a name="input_opensearch_instance_type"></a> [opensearch\_instance\_type](#input\_opensearch\_instance\_type) | OpenSearch node instance type. | `string` | n/a | yes |
| <a name="input_opensearch_master_username"></a> [opensearch\_master\_username](#input\_opensearch\_master\_username) | OpenSearch master username. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs used by the data plane. | `list(string)` | n/a | yes |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | Allocated RDS storage in GB. | `number` | n/a | yes |
| <a name="input_rds_backup_retention_period"></a> [rds\_backup\_retention\_period](#input\_rds\_backup\_retention\_period) | Number of days to retain RDS automated backups. Set to 0 to disable backups. | `number` | `7` | no |
| <a name="input_rds_deletion_protection"></a> [rds\_deletion\_protection](#input\_rds\_deletion\_protection) | Whether to enable deletion protection on RDS. | `bool` | n/a | yes |
| <a name="input_rds_engine_version"></a> [rds\_engine\_version](#input\_rds\_engine\_version) | PostgreSQL engine version. | `string` | n/a | yes |
| <a name="input_rds_family"></a> [rds\_family](#input\_rds\_family) | Parameter group family for PostgreSQL. | `string` | n/a | yes |
| <a name="input_rds_ingress_cidr_blocks"></a> [rds\_ingress\_cidr\_blocks](#input\_rds\_ingress\_cidr\_blocks) | Additional CIDR blocks allowed to reach the RDS instance on port 5432. Useful for direct database access from a bastion or developer machine. | `list(string)` | `[]` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | RDS instance class. | `string` | n/a | yes |
| <a name="input_rds_multi_az"></a> [rds\_multi\_az](#input\_rds\_multi\_az) | Whether to enable Multi-AZ on RDS. | `bool` | n/a | yes |
| <a name="input_rds_skip_final_snapshot"></a> [rds\_skip\_final\_snapshot](#input\_rds\_skip\_final\_snapshot) | Whether to skip the final snapshot on deletion. | `bool` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#input\_secrets\_kms\_key\_id) | KMS key ID or ARN used to encrypt AWS Secrets Manager secrets. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used by the data plane. | `string` | n/a | yes |

----
### Modules

No modules.

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | OpenSearch endpoint. |
| <a name="output_opensearch_secret_arn"></a> [opensearch\_secret\_arn](#output\_opensearch\_secret\_arn) | Secrets Manager ARN for the OpenSearch credentials. |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS endpoint value. |
| <a name="output_rds_host"></a> [rds\_host](#output\_rds\_host) | Hostname used by the OpenMetadata application to connect to PostgreSQL. |
| <a name="output_rds_secret_arn"></a> [rds\_secret\_arn](#output\_rds\_secret\_arn) | Secrets Manager ARN for the RDS credentials. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

----
### Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_secretsmanager_secret.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.opensearch_from_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rds_from_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rds_from_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.final_snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.opensearch](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.rds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

----
<!-- END_TF_DOCS -->
