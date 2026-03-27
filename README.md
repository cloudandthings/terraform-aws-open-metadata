# Terraform AWS Module Template

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-~%3E%201.0-623CE4?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D%205%2C%20%3C%207-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Tests](https://img.shields.io/badge/tests-pytest-blue?logo=pytest)](./tests)

## Description

*...example content; edit as needed...*

Terraform module for...

Features:

 - Creates an...

[AWS documentation](https://docs.aws.amazon.com...)

----
## Prerequisites

*...example content; edit as needed...*

None.

----
## Usage

*...example content; edit as needed...*

See `examples` dropdown on Terraform Cloud, or [browse here](/examples/).

----
## Testing

*...example content; edit as needed...*

This module is tested during development using [`pytest`](https://docs.pytest.org/en/7.2.x/) and [`tftest`](https://pypi.org/project/tftest/). See the `tests` folder for further details, and in particular the [testing readme](./tests/README.md).

----
## Notes

*...example content; edit as needed...*

*This repo was created from [terraform-aws-template](https://github.com/cloudandthings/terraform-aws-template)*


----
## Known issues

*...example content; edit as needed...*

None at this time.

----
## Contributing

*...example content; edit as needed...*

Direct contributions are welcome.

See [`CONTRIBUTING.md`](./.github/CONTRIBUTING.md) for further information.

<!-- BEGIN_TF_DOCS -->
----
## Documentation

----
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Naming prefix for created resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of additional tags to assign to created resources. If configured with a provider `default_tags` configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |

----
### Modules

No modules.

----
### Outputs

No outputs.

----
### Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.1 |

----
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5, < 7 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |

----
### Resources

| Name | Type |
|------|------|
| [null_resource.delete_me](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

----
<!-- END_TF_DOCS -->
