<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_api_ingress_cidr_blocks"></a> [cluster\_api\_ingress\_cidr\_blocks](#input\_cluster\_api\_ingress\_cidr\_blocks) | CIDR ranges allowed to reach the private EKS API. | `list(string)` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create the cluster resources. | `bool` | `true` | no |
| <a name="input_create_node_group"></a> [create\_node\_group](#input\_create\_node\_group) | Whether to create the default managed node group. | `bool` | `true` | no |
| <a name="input_eks_node_ami_id"></a> [eks\_node\_ami\_id](#input\_eks\_node\_ami\_id) | AMI ID for the EKS managed node group. | `string` | n/a | yes |
| <a name="input_eks_node_ami_type"></a> [eks\_node\_ami\_type](#input\_eks\_node\_ami\_type) | AMI type for the EKS managed node group. | `string` | `"AL2023_ARM_64_STANDARD"` | no |
| <a name="input_eks_node_desired_size"></a> [eks\_node\_desired\_size](#input\_eks\_node\_desired\_size) | Desired size of the default node group. | `number` | n/a | yes |
| <a name="input_eks_node_instance_type"></a> [eks\_node\_instance\_type](#input\_eks\_node\_instance\_type) | Instance type for the default node group. | `string` | n/a | yes |
| <a name="input_eks_node_max_size"></a> [eks\_node\_max\_size](#input\_eks\_node\_max\_size) | Maximum size of the default node group. | `number` | n/a | yes |
| <a name="input_eks_node_min_size"></a> [eks\_node\_min\_size](#input\_eks\_node\_min\_size) | Minimum size of the default node group. | `number` | n/a | yes |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path of the IAM role. If not specified then the default of '/' is used. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary applied to cluster IAM roles. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key used for cluster secret encryption. | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the EKS cluster. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name prefix for cluster resources. | `string` | n/a | yes |
| <a name="input_oidc_thumbprints"></a> [oidc\_thumbprints](#input\_oidc\_thumbprints) | Custom OIDC root CA thumbprints. Required when include\_oidc\_root\_ca\_thumbprint is false. | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs for the cluster. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used by the cluster. | `string` | n/a | yes |

----
### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 21.15 |

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_data"></a> [cluster\_ca\_data](#output\_cluster\_ca\_data) | Base64-encoded certificate authority data for the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for the EKS cluster API server. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Cluster security group ID. |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | Node security group ID. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN for IRSA. |

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

----
### Resources

| Name | Type |
|------|------|
| [aws_vpc_security_group_ingress_rule.eks_api_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

----
<!-- END_TF_DOCS -->
