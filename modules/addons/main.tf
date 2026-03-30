check "cluster_input_aws_lb_controller" {
  assert {
    condition = !var.create || (
      (!var.create_aws_load_balancer_controller || (var.cluster_name != null && var.oidc_provider_arn != null))
    )
    error_message = "cluster_name and oidc_provider_arn must be provided when creating AWS Load Balancer Controller."
  }
}

check "cluster_input_external_secrets_operator" {
  assert {
    condition = !var.create || (
      (!var.create_external_secrets_operator || var.cluster_name != null)
    )
    error_message = "cluster_name must be provided when creating External Secrets Operator."
  }
}

module "lb_controller_irsa" {
  count = var.create && var.create_aws_load_balancer_controller ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.4"

  name                 = "${var.name_prefix}-lb-ctrl-irsa"
  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  count = var.create && var.create_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_lb_controller_chart_version
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_irsa[0].arn
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  depends_on = [module.lb_controller_irsa]
}

resource "helm_release" "external_secrets" {
  count = var.create && var.create_external_secrets_operator ? 1 : 0

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.external_secrets_chart_version
  namespace  = "external-secrets"

  create_namespace = true
  timeout          = 600

  set {
    name  = "installCRDs"
    value = "true"
  }
}
