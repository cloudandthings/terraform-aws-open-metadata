locals {
  namespace_name         = var.namespace
  create_acm_certificate = var.create && var.create_ingress && var.enable_tls && var.acm_private_ca_arn != null && var.openmetadata_fqdn != null

  # Generic, user-defined chart values pass-through.
  openmetadata_helm_set_values_filtered = {
    for key, value in var.openmetadata_helm_set_values : key => value if value != null
  }

  # Built-in ExternalSecrets for OpenMetadata runtime dependencies.
  required_external_secrets = var.create && var.create_openmetadata_release ? {
    (var.database_secret_ref) = {
      secret_arn      = var.database_secret_arn
      secret_key      = var.database_secret_key
      secret_property = var.database_secret_property
    }
    (var.opensearch_secret_ref) = {
      secret_arn      = var.opensearch_secret_arn
      secret_key      = var.opensearch_secret_key
      secret_property = var.opensearch_secret_property
    }
  } : {}

  # User-provided secrets are merged with the built-in DB/OpenSearch entries.
  # Built-in entries win to keep runtime secret names stable for the chart.
  combined_external_secrets = merge(var.openmetadata_external_secrets, local.required_external_secrets)
}

check "release_inputs" {
  assert {
    condition = !var.create || !var.create_openmetadata_release || (
      var.database_host != null &&
      var.database_secret_arn != null &&
      var.opensearch_endpoint != null &&
      var.opensearch_secret_arn != null &&
      var.oidc_provider_arn != null
    )
    error_message = "database_host, database_secret_arn, opensearch_endpoint, opensearch_secret_arn, and oidc_provider_arn must be provided when creating the OpenMetadata release."
  }
}

check "ingress_requires_release" {
  assert {
    condition     = !var.create || !var.create_ingress || var.create_openmetadata_release
    error_message = "create_ingress currently requires create_openmetadata_release = true."
  }
}

check "ingress_network_inputs" {
  assert {
    condition     = !var.create || !var.create_ingress || var.node_security_group_id != null
    error_message = "node_security_group_id must be provided when create_ingress is true."
  }
}

check "ingress_tls_inputs" {
  assert {
    condition     = !var.create || !var.create_ingress || !var.enable_tls || (var.acm_private_ca_arn != null && var.openmetadata_fqdn != null)
    error_message = "acm_private_ca_arn and openmetadata_fqdn must be provided when enable_tls is true."
  }
}

resource "kubernetes_namespace" "openmetadata" {
  count = var.create && var.create_namespace ? 1 : 0

  metadata {
    name = local.namespace_name
  }
}

module "openmetadata_irsa" {
  count = var.create && var.create_openmetadata_release ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.4"

  name                 = "${var.name_prefix}-irsa"
  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "${local.namespace_name}:openmetadata",
        "${local.namespace_name}:openmetadata-ingestion",
      ]
    }
  }

  policies = {
    glue_read       = aws_iam_policy.openmetadata_glue_s3[0].arn
    secrets_manager = aws_iam_policy.openmetadata_secrets[0].arn
  }
}

resource "aws_iam_policy" "openmetadata_secrets" {
  count = var.create && var.create_openmetadata_release ? 1 : 0

  name        = "${var.name}-openmetadata-secrets"
  path        = var.iam_role_path
  description = "Allow OpenMetadata to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid      = "SecretsManagerRead"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [for secret in values(local.combined_external_secrets) : secret.secret_arn]
      },
      ], length(var.openmetadata_external_secret_kms_key_arns) > 0 ? [
      {
        Sid    = "SecretsManagerDecrypt"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
        ]
        Resource = var.openmetadata_external_secret_kms_key_arns
      }
    ] : [])
  })
}

resource "aws_iam_policy" "openmetadata_glue_s3" {
  count = var.create && var.create_openmetadata_release ? 1 : 0

  name        = "${var.name}-openmetadata-glue-s3"
  path        = var.iam_role_path
  description = "Allow OpenMetadata to read Glue catalog and list S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GlueReadAccess"
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:SearchTables",
          "glue:GetConnection",
          "glue:GetConnections",
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ListAccess"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "kubernetes_service_account" "openmetadata" {
  count = var.create && var.create_openmetadata_release ? 1 : 0

  metadata {
    name      = "openmetadata"
    namespace = local.namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.openmetadata_irsa[0].arn
    }
  }

  depends_on = [
    kubernetes_namespace.openmetadata,
    module.openmetadata_irsa,
  ]
}

resource "kubernetes_manifest" "openmetadata_secret_store" {
  count = var.create && var.create_openmetadata_release && length(local.combined_external_secrets) > 0 ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = var.openmetadata_external_secret_store_name
      namespace = local.namespace_name
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name = "openmetadata"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.openmetadata,
    kubernetes_service_account.openmetadata,
  ]
}

# External Secrets Operator resources for OpenMetadata secrets.
# ESO syncs both built-in runtime credentials and user-provided secrets from AWS Secrets Manager.
resource "kubernetes_manifest" "openmetadata_external_secret" {
  for_each = local.combined_external_secrets

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = local.namespace_name
    }
    spec = {
      secretStoreRef = {
        name = var.openmetadata_external_secret_store_name
        kind = "SecretStore"
      }
      target = {
        name           = each.key
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = each.value.secret_key
          remoteRef = merge(
            {
              key = each.value.secret_arn
            },
            try(each.value.secret_property, null) != null ? {
              property = each.value.secret_property
            } : {}
          )
        }
      ]
    }
  }

  depends_on = [
    kubernetes_namespace.openmetadata,
    kubernetes_manifest.openmetadata_secret_store,
  ]
}

resource "helm_release" "openmetadata" {
  count = var.create && var.create_openmetadata_release ? 1 : 0

  name       = "openmetadata"
  repository = "https://helm.open-metadata.org"
  chart      = "openmetadata"
  version    = var.openmetadata_chart_version
  namespace  = local.namespace_name

  timeout = 600

  set {
    name  = "openmetadata.config.database.host"
    value = var.database_host
  }
  set {
    name  = "openmetadata.config.database.port"
    value = "5432"
  }
  set {
    name  = "openmetadata.config.database.driverClass"
    value = "org.postgresql.Driver"
  }
  set {
    name  = "openmetadata.config.database.dbScheme"
    value = "postgresql"
  }
  set {
    name  = "openmetadata.config.database.databaseName"
    value = var.database_name
  }
  set {
    name  = "openmetadata.config.database.auth.username"
    value = var.database_username
  }
  set {
    name  = "openmetadata.config.database.auth.password.secretRef"
    value = var.database_secret_ref
  }
  set {
    name  = "openmetadata.config.database.auth.password.secretKey"
    value = var.database_secret_key
  }

  set {
    name  = "openmetadata.config.elasticsearch.host"
    value = var.opensearch_endpoint
  }
  set {
    name  = "openmetadata.config.elasticsearch.searchType"
    value = "opensearch"
  }
  set {
    name  = "openmetadata.config.elasticsearch.port"
    value = "443"
  }
  set {
    name  = "openmetadata.config.elasticsearch.scheme"
    value = "https"
  }
  set {
    name  = "openmetadata.config.elasticsearch.auth.enabled"
    value = "true"
  }
  set {
    name  = "openmetadata.config.elasticsearch.auth.username"
    value = var.opensearch_master_username
  }
  set {
    name  = "openmetadata.config.elasticsearch.auth.password.secretRef"
    value = var.opensearch_secret_ref
  }
  set {
    name  = "openmetadata.config.elasticsearch.auth.password.secretKey"
    value = var.opensearch_secret_key
  }
  set {
    name  = "openmetadata.config.elasticsearch.connectionTimeoutSecs"
    value = "5"
  }
  set {
    name  = "openmetadata.config.elasticsearch.socketTimeoutSecs"
    value = "60"
  }
  set {
    name  = "openmetadata.config.elasticsearch.keepAliveTimeoutSecs"
    value = "600"
  }
  set {
    name  = "openmetadata.config.elasticsearch.batchSize"
    value = "10"
  }

  set {
    name  = "openmetadata.config.pipelineServiceClientConfig.enabled"
    value = "true"
  }
  set {
    name  = "openmetadata.config.pipelineServiceClientConfig.type"
    value = "k8s"
  }
  set {
    name  = "openmetadata.config.pipelineServiceClientConfig.metadataApiEndpoint"
    value = "http://openmetadata:8585/api"
  }

  set {
    name  = "openmetadata.config.pipelineServiceClientConfig.k8s.ingestionImage"
    value = "docker.getcollate.io/openmetadata/ingestion-base:${var.openmetadata_chart_version}"
  }
  set {
    name  = "openmetadata.config.pipelineServiceClientConfig.k8s.useOMJobOperator"
    value = "true"
  }
  set {
    name  = "omjobOperator.enabled"
    value = "true"
  }
  set {
    name  = "omjobOperator.image.repository"
    value = "docker.getcollate.io/openmetadata/omjob-operator"
  }
  set {
    name  = "omjobOperator.image.tag"
    value = var.openmetadata_chart_version
  }

  set {
    name  = "extraEnvs[0].name"
    value = "OPENMETADATA_HEAP_OPTS"
  }
  set {
    name  = "extraEnvs[0].value"
    value = var.openmetadata_heap_opts
  }

  # Generic user-defined Helm values
  dynamic "set" {
    for_each = local.openmetadata_helm_set_values_filtered
    content {
      name  = set.key
      value = tostring(set.value)
    }
  }

  dynamic "set_sensitive" {
    for_each = toset(nonsensitive(keys(var.openmetadata_helm_set_sensitive_values)))
    content {
      name  = set_sensitive.value
      value = var.openmetadata_helm_set_sensitive_values[set_sensitive.value]
    }
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "openmetadata"
  }

  depends_on = [
    kubernetes_namespace.openmetadata,
    kubernetes_service_account.openmetadata,
    module.openmetadata_irsa,
    kubernetes_manifest.openmetadata_secret_store,
    kubernetes_manifest.openmetadata_external_secret,
  ]
}

resource "aws_acm_certificate" "openmetadata" {
  count = local.create_acm_certificate ? 1 : 0

  domain_name               = var.openmetadata_fqdn
  certificate_authority_arn = var.acm_private_ca_arn

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb" {
  count = var.create && var.create_ingress ? 1 : 0

  name_prefix = "${var.name}-alb-"
  description = "Allow HTTP/HTTPS access to OpenMetadata ALB from internal network"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = var.create && var.create_ingress ? toset(var.ingress_cidr_blocks) : toset([])

  security_group_id = aws_security_group.alb[0].id
  description       = local.create_acm_certificate ? "HTTP inbound (redirects to HTTPS)" : "HTTP inbound to OpenMetadata UI/API"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = local.create_acm_certificate ? toset(var.ingress_cidr_blocks) : toset([])

  security_group_id = aws_security_group.alb[0].id
  description       = "HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "alb_to_openmetadata" {
  count = var.create && var.create_ingress ? 1 : 0

  security_group_id            = aws_security_group.alb[0].id
  description                  = "Allow ALB to reach OpenMetadata pods"
  from_port                    = 8585
  to_port                      = 8585
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.node_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_from_alb" {
  count = var.create && var.create_ingress ? 1 : 0

  security_group_id            = var.node_security_group_id
  description                  = "Allow ALB to reach OpenMetadata pods"
  from_port                    = 8585
  to_port                      = 8585
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb[0].id
}

resource "kubernetes_ingress_v1" "openmetadata" {
  count = var.create && var.create_ingress ? 1 : 0

  # Ensure ALB hostname is present in ingress status before dependent DNS evaluation.
  wait_for_load_balancer = true

  metadata {
    name      = "openmetadata"
    namespace = local.namespace_name

    annotations = merge(
      {
        "kubernetes.io/ingress.class"                    = "alb"
        "alb.ingress.kubernetes.io/scheme"               = "internal"
        "alb.ingress.kubernetes.io/target-type"          = "ip"
        "alb.ingress.kubernetes.io/listen-ports"         = jsonencode(local.create_acm_certificate ? [{ HTTP = 80 }, { HTTPS = 443 }] : [{ HTTP = 80 }])
        "alb.ingress.kubernetes.io/security-groups"      = aws_security_group.alb[0].id
        "alb.ingress.kubernetes.io/subnets"              = join(",", var.private_subnet_ids)
        "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
        "alb.ingress.kubernetes.io/healthcheck-port"     = "8585"
        "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
        "alb.ingress.kubernetes.io/tags"                 = join(",", [for key, value in var.tags : "${key}=${value}"])
      },
      local.create_acm_certificate ? {
        "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.openmetadata[0].arn
        "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-TLS-1-2-2017-01"
        "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      } : {}
    )
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "openmetadata"
              port {
                number = 8585
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.openmetadata]
}
