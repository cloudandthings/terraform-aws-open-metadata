# Unit tests for OpenSearch zone awareness — no AWS credentials required.
# Run with: tofu test
#       or: terraform test
#
# These target ./modules/data directly so the domain's cluster_config can be
# asserted without mock providers having to synthesise the computed ARNs that
# complex upstream modules (e.g. EKS) expect.

mock_provider "aws" {}
mock_provider "random" {}

variables {
  region                     = "af-south-1"
  account_id                 = "123456789012"
  name                       = "test-open-metadata"
  name_prefix                = "tom"
  vpc_id                     = "vpc-00000000000000000"
  private_subnet_ids         = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
  node_security_group_id     = "sg-00000000000000000"
  kms_key_id                 = "arn:aws:kms:af-south-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  create_rds                 = false
  existing_rds_endpoint      = "rds.example.com"
  existing_rds_secret_arn    = "arn:aws:secretsmanager:af-south-1:123456789012:secret:rds-000000"
  rds_instance_class         = "db.t3.medium"
  rds_engine_version         = "16.3"
  rds_family                 = "postgres16"
  rds_allocated_storage      = 20
  database_name              = "openmetadata"
  database_username          = "openmetadata"
  rds_multi_az               = false
  rds_skip_final_snapshot    = true
  rds_deletion_protection    = false
  opensearch_engine_version  = "OpenSearch_2.17"
  opensearch_instance_type   = "t3.small.search"
  opensearch_ebs_volume_size = 20
  opensearch_master_username = "openmetadata"
}

# A single node cannot be zone aware, and AWS accepts exactly one subnet.
run "single_node_disables_zone_awareness" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 1
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_enabled == false
    error_message = "Zone awareness must stay off for a single-node domain."
  }

  assert {
    condition     = length(aws_opensearch_domain.this[0].vpc_options[0].subnet_ids) == 1
    error_message = "A single-node domain must be given exactly one subnet."
  }

  assert {
    condition     = length(aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config) == 0
    error_message = "zone_awareness_config must be omitted when zone awareness is off."
  }
}

# The reported bug: two nodes passed two subnets without zone awareness on.
run "two_nodes_enable_zone_awareness_across_two_azs" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 2
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_enabled == true
    error_message = "Zone awareness must be enabled for a multi-node domain."
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config[0].availability_zone_count == 2
    error_message = "Two data nodes must spread across two availability zones."
  }

  assert {
    condition     = length(aws_opensearch_domain.this[0].vpc_options[0].subnet_ids) == 2
    error_message = "Subnet count must match the availability zone count."
  }
}

# Three or more nodes use three AZs when three subnets are available.
run "three_nodes_use_three_azs" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 3
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config[0].availability_zone_count == 3
    error_message = "Three data nodes must spread across three availability zones."
  }

  assert {
    condition     = length(aws_opensearch_domain.this[0].vpc_options[0].subnet_ids) == 3
    error_message = "Subnet count must match the availability zone count."
  }
}

# Scaling from 3 to 4 nodes must not drop back to two AZs: that would lose
# resilience and change the subnets, forcing a blue/green deployment.
run "four_nodes_stay_on_three_azs" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 4
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config[0].availability_zone_count == 3
    error_message = "Four data nodes must spread across three availability zones."
  }
}

# Without a third subnet, an even node count uses two AZs.
run "four_nodes_with_two_subnets_use_two_azs" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 4
    private_subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config[0].availability_zone_count == 2
    error_message = "Four data nodes with two subnets must spread across two availability zones."
  }
}

# Three AZs need three subnets. Falling back to two would leave three data nodes
# spread over two zones, which AWS rejects, so the domain must refuse to plan.
run "three_nodes_with_two_subnets_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 3
    private_subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }

  expect_failures = [aws_opensearch_domain.this]
}

# Too few subnets must fail on the domain's precondition, not on an opaque
# slice() error raised while evaluating locals.
run "two_nodes_with_one_subnet_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 2
    private_subnet_ids        = ["subnet-00000000000000001"]
  }

  expect_failures = [aws_opensearch_domain.this]
}

# A caller bringing their own domain is unaffected by the subnet requirements,
# even though the locals that derive them are still evaluated.
run "existing_domain_ignores_subnet_requirements" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    create_opensearch              = false
    opensearch_instance_count      = 2
    private_subnet_ids             = ["subnet-00000000000000001"]
    existing_opensearch_endpoint   = "opensearch.example.com"
    existing_opensearch_secret_arn = "arn:aws:secretsmanager:af-south-1:123456789012:secret:os-000000"
  }

  assert {
    condition     = length(aws_opensearch_domain.this) == 0
    error_message = "No domain must be planned when create_opensearch is false."
  }
}

# private_subnet_ids may hold several subnets per availability zone, so callers
# can name the ones the domain should use.
run "explicit_subnet_ids_override_private_subnets" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 2
    private_subnet_ids = [
      "subnet-0000000000000000a",
      "subnet-0000000000000000b",
      "subnet-0000000000000000c",
    ]
    opensearch_subnet_ids = [
      "subnet-0000000000000000a",
      "subnet-0000000000000000c",
    ]
  }

  assert {
    condition = aws_opensearch_domain.this[0].vpc_options[0].subnet_ids == toset([
      "subnet-0000000000000000a",
      "subnet-0000000000000000c",
    ])
    error_message = "opensearch_subnet_ids must select the domain's subnets."
  }
}

# AWS accepts node counts that are not a multiple of 3 across three AZs.
run "five_nodes_use_three_azs" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 5
  }

  assert {
    condition     = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_config[0].availability_zone_count == 3
    error_message = "Five data nodes must spread across three availability zones."
  }
}

# Two AZs need an even node count.
run "five_nodes_with_two_subnets_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 5
    private_subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
  }

  expect_failures = [aws_opensearch_domain.this]
}

# Zero and fractional node counts are not valid domain sizes.
run "zero_node_count_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 0
  }

  expect_failures = [var.opensearch_instance_count]
}

run "fractional_node_count_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 2.5
  }

  expect_failures = [var.opensearch_instance_count]
}

# An empty override would otherwise only fail later, on the domain precondition.
run "empty_opensearch_subnet_ids_is_rejected" {
  command = plan

  module {
    source = "./modules/data"
  }

  variables {
    opensearch_instance_count = 2
    opensearch_subnet_ids     = []
  }

  expect_failures = [var.opensearch_subnet_ids]
}
