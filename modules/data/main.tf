check "existing_rds_inputs" {
  assert {
    condition     = !var.create || var.create_rds || (var.existing_rds_endpoint != null && var.existing_rds_secret_arn != null)
    error_message = "existing_rds_endpoint and existing_rds_secret_arn must be provided when create_rds is false."
  }
}

check "existing_opensearch_inputs" {
  assert {
    condition     = !var.create || var.create_opensearch || (var.existing_opensearch_endpoint != null && var.existing_opensearch_secret_arn != null)
    error_message = "existing_opensearch_endpoint and existing_opensearch_secret_arn must be provided when create_opensearch is false."
  }
}

check "managed_rds_secret_support" {
  assert {
    condition     = !var.create || !var.create_rds || var.create_rds_secret
    error_message = "Managed RDS creation currently requires create_rds_secret = true. Use existing_rds_secret_arn when bringing your own secret."
  }
}

check "managed_opensearch_secret_support" {
  assert {
    condition     = !var.create || !var.create_opensearch || var.create_opensearch_secret
    error_message = "Managed OpenSearch creation currently requires create_opensearch_secret = true. Use existing_opensearch_secret_arn when bringing your own secret."
  }
}

resource "aws_security_group" "rds" {
  count = var.create && var.create_rds ? 1 : 0

  name_prefix = "${var.name}-rds-"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  count = var.create && var.create_rds ? 1 : 0

  security_group_id            = aws_security_group.rds[0].id
  description                  = "PostgreSQL from EKS nodes"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.node_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_cidr" {
  for_each = (var.create && var.create_rds) ? toset(var.rds_ingress_cidr_blocks) : toset([])

  security_group_id = aws_security_group.rds[0].id
  description       = "PostgreSQL from ${each.key}"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = each.key
}


resource "random_password" "rds" {
  count = var.create && var.create_rds ? 1 : 0

  length  = 32
  special = true
  # RDS master passwords cannot contain /, @, ", or spaces.
  override_special = "!#$%^&*()_+-="
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "rds" {
  count = var.create && var.create_rds && var.create_rds_secret ? 1 : 0

  name        = "${var.name}/rds"
  description = "RDS PostgreSQL master password for OpenMetadata"
  kms_key_id  = var.secrets_kms_key_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "rds" {
  count = var.create && var.create_rds && var.create_rds_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode({
    username = var.database_username
    password = random_password.rds[0].result
  })
}

resource "aws_db_subnet_group" "this" {
  count = var.create && var.create_rds ? 1 : 0

  name       = "${var.name}-rds"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_parameter_group" "this" {
  count = var.create && var.create_rds ? 1 : 0

  name   = "${var.name}-rds-pg"
  family = var.rds_family

  parameter {
    name  = "work_mem"
    value = "20480"
  }
}

resource "random_id" "final_snapshot_suffix" {
  byte_length = 4
}

locals {
  final_snapshot_identifier = (
    var.rds_skip_final_snapshot
    ? null
    : "${var.name}-rds-final-snapshot-${random_id.final_snapshot_suffix.hex}"
  )
}

resource "aws_db_instance" "this" {
  count = var.create && var.create_rds ? 1 : 0

  identifier = "${var.name}-rds"

  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  allocated_storage = var.rds_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  db_name  = var.database_name
  username = var.database_username
  password = random_password.rds[0].result

  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  parameter_group_name   = aws_db_parameter_group.this[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  publicly_accessible    = false

  multi_az                  = var.rds_multi_az
  skip_final_snapshot       = var.rds_skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  deletion_protection       = var.rds_deletion_protection

  backup_retention_period = var.rds_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
}

resource "aws_security_group" "opensearch" {
  count = var.create && var.create_opensearch ? 1 : 0

  name_prefix = "${var.name}-opensearch-"
  description = "Allow HTTPS access from EKS nodes"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "opensearch_from_eks" {
  count = var.create && var.create_opensearch ? 1 : 0

  security_group_id            = aws_security_group.opensearch[0].id
  description                  = "HTTPS from EKS nodes"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.node_security_group_id
}


resource "random_password" "opensearch" {
  count = var.create && var.create_opensearch ? 1 : 0

  length           = 32
  special          = true
  override_special = "!@#$%^&*()_+-="
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "opensearch" {
  count = var.create && var.create_opensearch && var.create_opensearch_secret ? 1 : 0

  name        = "${var.name}/opensearch"
  description = "OpenSearch master password for OpenMetadata"
  kms_key_id  = var.secrets_kms_key_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "opensearch" {
  count = var.create && var.create_opensearch && var.create_opensearch_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.opensearch[0].id
  secret_string = jsonencode({
    username = var.opensearch_master_username
    password = random_password.opensearch[0].result
  })
}

resource "aws_opensearch_domain" "this" {
  count = var.create && var.create_opensearch ? 1 : 0

  domain_name    = "${var.name_prefix}-os"
  engine_version = var.opensearch_engine_version

  cluster_config {
    instance_type  = var.opensearch_instance_type
    instance_count = var.opensearch_instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.opensearch_ebs_volume_size
  }

  vpc_options {
    subnet_ids         = slice(var.private_subnet_ids, 0, min(var.opensearch_instance_count, length(var.private_subnet_ids)))
    security_group_ids = [aws_security_group.opensearch[0].id]
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.opensearch_master_username
      master_user_password = random_password.opensearch[0].result
    }
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "es:*"
        Resource  = "arn:aws:es:${var.region}:${var.account_id}:domain/${var.name_prefix}-os/*"
      }
    ]
  })
}
