# Variable Renames

This document records all input variable renames applied in the initial naming cleanup.
The renames align the module's public interface with [terraform-aws-modules](https://github.com/terraform-aws-modules) conventions.

## Root module (`variables.tf`)

| Old name | New name | Reason |
|---|---|---|
| `general_name` | `name` | Standard terraform-aws-modules convention; "general" adds no meaning |
| `short_name_prefix` | `name_prefix` | Idiomatic HCL convention; the description now explains the length constraint |
| `eks_cluster_version` | `kubernetes_version` | Matches upstream `terraform-aws-modules/eks`; avoids confusion with EKS platform version |
| `bank_cidrs` | `ingress_cidr_blocks` | Internal organisation name leaked into the public interface; standard ALB/ingress convention |
| `aws_route53_zone` | `route53_zone_name` | Variables are never prefixed with provider names (`aws_`); `_name` clarifies it is a zone name string |
| `openmetadata_namespace` | `namespace` | Redundant `openmetadata_` prefix; `namespace` matches Kubernetes/Helm Terraform modules |
| `data_kms_key` | `kms_key_id` | "data" under-describes scope (used for EKS, RDS, and OpenSearch); `_id` matches terraform-aws-modules/rds and terraform-aws-modules/eks KMS variable names |
| `secrets_kms_key` | `secrets_kms_key_id` | Adds `_id` suffix for consistency with `kms_key_id` and to clarify the expected value type |

## `modules/cluster/variables.tf`

| Old name | New name | Reason |
|---|---|---|
| `general_name` | `name` | Aligns with root rename |
| `eks_cluster_version` | `kubernetes_version` | Aligns with root rename |
| `data_kms_key` | `kms_key_id` | Aligns with root rename |

## `modules/addons/variables.tf`

| Old name | New name | Reason |
|---|---|---|
| `short_name_prefix` | `name_prefix` | Aligns with root rename |

## `modules/data/variables.tf`

| Old name | New name | Reason |
|---|---|---|
| `general_name` | `name` | Aligns with root rename |
| `short_name_prefix` | `name_prefix` | Aligns with root rename |
| `data_kms_key` | `kms_key_id` | Aligns with root rename |
| `secrets_kms_key` | `secrets_kms_key_id` | Aligns with root rename |
| `rds_db_name` | `database_name` | Root and app modules already used `database_name`; removes internal inconsistency |
| `rds_username` | `database_username` | Root and app modules already used `database_username`; removes internal inconsistency |

## `modules/app/variables.tf`

| Old name | New name | Reason |
|---|---|---|
| `general_name` | `name` | Aligns with root rename |
| `short_name_prefix` | `name_prefix` | Aligns with root rename |
| `bank_cidrs` | `ingress_cidr_blocks` | Aligns with root rename |
| `namespace_name` | `namespace` | Aligns with root rename; removes redundant `_name` suffix |

## `modules/dns/variables.tf`

| Old name | New name | Reason |
|---|---|---|
| `aws_route53_zone` | `route53_zone_name` | Aligns with root rename |

## Files updated

- `variables.tf`
- `main.tf`
- `data.tf`
- `modules/cluster/variables.tf`, `main.tf`
- `modules/addons/variables.tf`, `main.tf`
- `modules/data/variables.tf`, `main.tf`
- `modules/app/variables.tf`, `main.tf`, `outputs.tf`
- `modules/dns/variables.tf`, `main.tf`
- `examples/basic/main.tf`, `variables.tf`
- `tests/basic.tftest.hcl`
