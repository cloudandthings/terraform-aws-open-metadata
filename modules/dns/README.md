<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create DNS resources. | `bool` | `true` | no |
| <a name="input_ingress_hostname"></a> [ingress\_hostname](#input\_ingress\_hostname) | ALB hostname from the Kubernetes ingress. The record is only created once this is known. | `string` | `null` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Private Route53 hosted zone name. | `string` | n/a | yes |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain for the Route53 CNAME record. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID used for the private hosted zone lookup. | `string` | n/a | yes |

----
### Modules

No modules.

----
### Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN of the Route53 CNAME record created for OpenMetadata. |

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
| [aws_route53_record.openmetadata_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.openmetadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

----
<!-- END_TF_DOCS -->
