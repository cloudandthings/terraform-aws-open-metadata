<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_private_ca_arn"></a> [acm\_private\_ca\_arn](#input\_acm\_private\_ca\_arn) | Private CA ARN used to issue the ingress certificate. | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create app resources. | `bool` | `true` | no |
| <a name="input_create_ingress"></a> [create\_ingress](#input\_create\_ingress) | Whether to create ingress, ALB security groups, DNS, and TLS resources. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the Kubernetes namespace. | `bool` | `true` | no |
| <a name="input_create_openmetadata_release"></a> [create\_openmetadata\_release](#input\_create\_openmetadata\_release) | Whether to install the OpenMetadata Helm release. | `bool` | `true` | no |
| <a name="input_database_host"></a> [database\_host](#input\_database\_host) | Database host used by OpenMetadata. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name for OpenMetadata. | `string` | n/a | yes |
| <a name="input_database_secret_arn"></a> [database\_secret\_arn](#input\_database\_secret\_arn) | AWS Secrets Manager secret ARN used as the source for the OpenMetadata DB password. | `string` | `null` | no |
| <a name="input_database_secret_key"></a> [database\_secret\_key](#input\_database\_secret\_key) | Key name created inside the Kubernetes Secret target (for example openmetadata-db-password). This is not the AWS Secrets Manager JSON property name. | `string` | `"openmetadata-db-password"` | no |
| <a name="input_database_secret_property"></a> [database\_secret\_property](#input\_database\_secret\_property) | Optional JSON property to extract from the AWS Secrets Manager secret value (remoteRef.property). Leave null when the secret value is already a plain string. Example: password. | `string` | `null` | no |
| <a name="input_database_secret_ref"></a> [database\_secret\_ref](#input\_database\_secret\_ref) | Kubernetes Secret name consumed by the OpenMetadata chart for the DB password (openmetadata.config.database.auth.password.secretRef). | `string` | `"openmetadata-db-secrets"` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Database username used by OpenMetadata. | `string` | n/a | yes |
| <a name="input_enable_tls"></a> [enable\_tls](#input\_enable\_tls) | Whether to enable TLS for the ingress. | `bool` | `false` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role. If not specified then the default of '/' is used. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary applied to app IAM roles. | `string` | n/a | yes |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | CIDR ranges allowed inbound to the OpenMetadata ALB. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name prefix for app-owned resources. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Short prefix for IRSA naming. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for OpenMetadata. | `string` | n/a | yes |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | Node security group ID allowed to receive ALB traffic. | `string` | `null` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | OIDC provider ARN used for the OpenMetadata IRSA role. | `string` | `null` | no |
| <a name="input_openmetadata_chart_version"></a> [openmetadata\_chart\_version](#input\_openmetadata\_chart\_version) | OpenMetadata Helm chart version. | `string` | n/a | yes |
| <a name="input_openmetadata_external_secret_kms_key_arns"></a> [openmetadata\_external\_secret\_kms\_key\_arns](#input\_openmetadata\_external\_secret\_kms\_key\_arns) | Optional list of KMS key ARNs to allow for decrypt when synced Secrets Manager secrets use customer-managed KMS keys. | `list(string)` | `[]` | no |
| <a name="input_openmetadata_external_secret_store_name"></a> [openmetadata\_external\_secret\_store\_name](#input\_openmetadata\_external\_secret\_store\_name) | SecretStore name used by ExternalSecret resources. | `string` | `"aws-secrets"` | no |
| <a name="input_openmetadata_external_secrets"></a> [openmetadata\_external\_secrets](#input\_openmetadata\_external\_secrets) | Additional ExternalSecret entries keyed by Kubernetes Secret name. secret\_arn is the AWS source secret, secret\_key is the key written inside the Kubernetes Secret, and optional secret\_property selects a JSON field from the AWS secret value. | <pre>map(object({<br/>    secret_arn      = string<br/>    secret_key      = optional(string, "value")<br/>    secret_property = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_openmetadata_fqdn"></a> [openmetadata\_fqdn](#input\_openmetadata\_fqdn) | Precomputed FQDN used for the ACM certificate. | `string` | `null` | no |
| <a name="input_openmetadata_heap_opts"></a> [openmetadata\_heap\_opts](#input\_openmetadata\_heap\_opts) | JVM heap options passed to OpenMetadata via OPENMETADATA\_HEAP\_OPTS. | `string` | `"-Xmx2G -Xms2G"` | no |
| <a name="input_openmetadata_helm_set_sensitive_values"></a> [openmetadata\_helm\_set\_sensitive\_values](#input\_openmetadata\_helm\_set\_sensitive\_values) | Generic sensitive Helm set values applied directly to the OpenMetadata chart via set\_sensitive. | `map(string)` | `{}` | no |
| <a name="input_openmetadata_helm_set_values"></a> [openmetadata\_helm\_set\_values](#input\_openmetadata\_helm\_set\_values) | Generic Helm set values applied directly to the OpenMetadata chart. Key is Helm path (for example openmetadata.config.authentication.provider), value is converted to string. | `map(any)` | `{}` | no |
| <a name="input_opensearch_endpoint"></a> [opensearch\_endpoint](#input\_opensearch\_endpoint) | OpenSearch endpoint used by OpenMetadata. | `string` | `null` | no |
| <a name="input_opensearch_master_username"></a> [opensearch\_master\_username](#input\_opensearch\_master\_username) | OpenSearch username used by OpenMetadata. | `string` | n/a | yes |
| <a name="input_opensearch_secret_arn"></a> [opensearch\_secret\_arn](#input\_opensearch\_secret\_arn) | AWS Secrets Manager secret ARN used as the source for the OpenSearch password. | `string` | `null` | no |
| <a name="input_opensearch_secret_key"></a> [opensearch\_secret\_key](#input\_opensearch\_secret\_key) | Key name created inside the Kubernetes Secret target (for example openmetadata-opensearch-password). This is not the AWS Secrets Manager JSON property name. | `string` | `"openmetadata-opensearch-password"` | no |
| <a name="input_opensearch_secret_property"></a> [opensearch\_secret\_property](#input\_opensearch\_secret\_property) | Optional JSON property to extract from the AWS Secrets Manager secret value (remoteRef.property). Leave null when the secret value is already a plain string. Example: password. | `string` | `null` | no |
| <a name="input_opensearch_secret_ref"></a> [opensearch\_secret\_ref](#input\_opensearch\_secret\_ref) | Kubernetes Secret name consumed by the OpenMetadata chart for the OpenSearch password (openmetadata.config.elasticsearch.auth.password.secretRef). | `string` | `"openmetadata-opensearch-secrets"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs used by the ALB. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region used by the External Secrets SecretStore. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to supported app resources. | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used by ALB-related resources. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_openmetadata_irsa"></a> [openmetadata\_irsa](#module\_openmetadata\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.4 |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ingress_hostname"></a> [ingress\_hostname](#output\_ingress\_hostname) | Load balancer hostname reported by the Kubernetes ingress. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace used by OpenMetadata. |
| <a name="output_openmetadata_irsa_role_arn"></a> [openmetadata\_irsa\_role\_arn](#output\_openmetadata\_irsa\_role\_arn) | IAM role ARN used by the OpenMetadata service account. |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | OpenMetadata Helm release name. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.17 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.35 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.35 |

----
### Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.openmetadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_iam_policy.openmetadata_glue_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.openmetadata_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.alb_to_openmetadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.eks_nodes_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [helm_release.openmetadata](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.openmetadata](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.openmetadata_external_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.openmetadata_secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.openmetadata](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.openmetadata](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

----
<!-- END_TF_DOCS -->
