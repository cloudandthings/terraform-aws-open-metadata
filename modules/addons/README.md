<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_lb_controller_chart_version"></a> [aws\_lb\_controller\_chart\_version](#input\_aws\_lb\_controller\_chart\_version) | Helm chart version for the AWS Load Balancer Controller. | `string` | `"3.1.0"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name. | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create addon resources. | `bool` | `true` | no |
| <a name="input_create_aws_load_balancer_controller"></a> [create\_aws\_load\_balancer\_controller](#input\_create\_aws\_load\_balancer\_controller) | Whether to install the AWS Load Balancer Controller. | `bool` | `true` | no |
| <a name="input_create_external_secrets_operator"></a> [create\_external\_secrets\_operator](#input\_create\_external\_secrets\_operator) | Whether to install the External Secrets Operator. | `bool` | `true` | no |
| <a name="input_external_secrets_chart_version"></a> [external\_secrets\_chart\_version](#input\_external\_secrets\_chart\_version) | Helm chart version for the External Secrets Operator. | `string` | `"2.2.0"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role. If not specified then the default of '/' is used. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary applied to addon IAM roles. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Short prefix for addon IAM resources. | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | OIDC provider ARN used by the addon IRSA role. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used by the AWS Load Balancer Controller. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lb_controller_irsa"></a> [lb\_controller\_irsa](#module\_lb\_controller\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.4 |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_load_balancer_controller_enabled"></a> [aws\_load\_balancer\_controller\_enabled](#output\_aws\_load\_balancer\_controller\_enabled) | Whether the AWS Load Balancer Controller release is enabled. |
| <a name="output_lb_controller_irsa_role_arn"></a> [lb\_controller\_irsa\_role\_arn](#output\_lb\_controller\_irsa\_role\_arn) | IRSA role ARN used by the AWS Load Balancer Controller. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.17 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |

----
### Resources

| Name | Type |
|------|------|
| [helm_release.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_secrets](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

----
<!-- END_TF_DOCS -->
