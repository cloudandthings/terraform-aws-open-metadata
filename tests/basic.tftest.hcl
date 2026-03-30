# Unit tests using mock providers — no AWS credentials required.
# Run with: tofu test
#       or: terraform test

mock_provider "aws" {}
mock_provider "helm" {}
mock_provider "kubernetes" {}
mock_provider "random" {}

variables {
  region                        = "af-south-1"
  account_id                    = "123456789012"
  name                          = "test-open-metadata"
  name_prefix                   = "tom"
  tags                          = {}
  iam_role_permissions_boundary = "arn:aws:iam::123456789012:policy/boundary"
  kms_key_id                    = "arn:aws:kms:af-south-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  vpc_id                        = "vpc-00000000000000000"
  private_subnet_ids            = ["subnet-00000000000000001", "subnet-00000000000000002"]
  kubernetes_version            = "1.32"
  eks_node_instance_type        = "m7g.xlarge"
  eks_node_desired_size         = 2
  eks_node_min_size             = 1
  eks_node_max_size             = 4
  eks_node_ami_id               = "ami-00000000000000000"
  database_name                 = "openmetadata"
  database_username             = "openmetadata"
  rds_instance_class            = "db.t3.medium"
  rds_engine_version            = "16.3"
  rds_family                    = "postgres16"
  rds_allocated_storage         = 20
  rds_multi_az                  = false
  rds_skip_final_snapshot       = true
  rds_deletion_protection       = false
  opensearch_engine_version     = "OpenSearch_2.17"
  opensearch_instance_type      = "t3.small.search"
  opensearch_instance_count     = 1
  opensearch_ebs_volume_size    = 20
  opensearch_master_username    = "openmetadata"
  namespace                     = "openmetadata"
}

# Verify module type-checking, variable validation, and check-block logic.
# create = false skips all child modules so mock providers don't need to
# synthesise the computed ARNs that complex upstream modules (e.g. EKS) expect.
# Full resource creation is covered by tests/integration/basic.tftest.hcl.
run "plan_succeeds" {
  command = plan

  variables {
    create = false
  }
}
