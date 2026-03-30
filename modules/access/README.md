<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_access_principals"></a> [cluster\_access\_principals](#input\_cluster\_access\_principals) | Keyed map of principals that should get cluster-scoped access. | <pre>map(object({<br/>    principal_arn = string<br/>    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name used for access entries. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create access resources. | `bool` | `true` | no |
| <a name="input_namespace_access_principals"></a> [namespace\_access\_principals](#input\_namespace\_access\_principals) | Keyed map of principals that should get namespace-scoped access. | <pre>map(object({<br/>    principal_arn = string<br/>    namespaces    = list(string)<br/>    policy_arn    = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy")<br/>  }))</pre> | `{}` | no |

----
### Modules

No modules.

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entry_ids"></a> [access\_entry\_ids](#output\_access\_entry\_ids) | IDs of the created EKS access resources. |

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
| [aws_eks_access_entry.principal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_access_policy_association.namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |

----
<!-- END_TF_DOCS -->
