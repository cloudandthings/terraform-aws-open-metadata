locals {
  all_principal_arns = toset(concat(
    [for principal in values(var.cluster_access_principals) : principal.principal_arn],
    [for principal in values(var.namespace_access_principals) : principal.principal_arn]
  ))

  principal_map = var.create ? {
    for principal_arn in local.all_principal_arns : principal_arn => principal_arn
  } : {}

  cluster_access_associations = var.create ? {
    for principal_key, principal in var.cluster_access_principals : principal_key => {
      principal_arn = principal.principal_arn
      policy_arn    = principal.policy_arn
    }
  } : {}

  namespace_access_pairs = var.create ? {
    for pair in flatten([
      for principal_key, principal in var.namespace_access_principals : [
        for namespace in distinct(principal.namespaces) : {
          key           = "${principal_key}/${namespace}"
          principal_arn = principal.principal_arn
          policy_arn    = principal.policy_arn
          namespace     = namespace
        }
      ]
    ]) : pair.key => pair
  } : {}
}

check "cluster_access_principal_arns_unique" {
  assert {
    condition     = !var.create || length(var.cluster_access_principals) == length(toset([for principal in values(var.cluster_access_principals) : principal.principal_arn]))
    error_message = "cluster_access_principals must not contain duplicate principal_arn values."
  }
}

check "namespace_access_inputs" {
  assert {
    condition     = !var.create || alltrue([for principal in values(var.namespace_access_principals) : length(principal.namespaces) > 0])
    error_message = "Each entry in namespace_access_principals must include at least one namespace."
  }
}

check "namespace_access_namespaces_unique" {
  assert {
    condition     = !var.create || alltrue([for principal in values(var.namespace_access_principals) : length(principal.namespaces) == length(toset(principal.namespaces))])
    error_message = "Each entry in namespace_access_principals must use unique namespace values."
  }
}

check "namespace_access_pairs_unique" {
  assert {
    condition = !var.create || length(flatten([
      for principal in values(var.namespace_access_principals) : [for namespace in principal.namespaces : "${principal.principal_arn}/${namespace}"]
      ])) == length(toset(flatten([
        for principal in values(var.namespace_access_principals) : [for namespace in principal.namespaces : "${principal.principal_arn}/${namespace}"]
    ])))
    error_message = "Duplicate principal_arn + namespace combinations are not allowed in namespace_access_principals."
  }
}

resource "aws_eks_access_entry" "principal" {
  for_each = local.principal_map

  cluster_name  = var.cluster_name
  principal_arn = each.key
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster" {
  for_each = local.cluster_access_associations

  cluster_name  = var.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.principal]
}

resource "aws_eks_access_policy_association" "namespace" {
  for_each = local.namespace_access_pairs

  cluster_name  = var.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = "namespace"
    namespaces = [each.value.namespace]
  }

  depends_on = [aws_eks_access_entry.principal]
}
