check "eks_node_startup_script" {
  # if eks_node_ami_type is BOTTLEROCKET_* or WINDOWS_*, eks_node_startup_script is ignored.
  assert {
    condition = (
      var.eks_node_startup_script == null ||
      startswith(var.eks_node_ami_type, "AL2_") ||
      startswith(var.eks_node_ami_type, "AL2023_")
    )
    error_message = "eks_node_startup_script is only supported for AL2 and AL2023 AMI types."
  }
}

# trivy:ignore:AVD-AWS-0104 Node egress_all is intentional — pods require unrestricted outbound to reach crawl targets.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15"

  create = var.create

  name               = "${var.name}-eks"
  kubernetes_version = var.kubernetes_version

  iam_role_name                 = "omd-eks-cluster"
  iam_role_use_name_prefix      = true
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_public_access  = false
  endpoint_private_access = true

  create_kms_key         = false
  encryption_policy_path = var.iam_role_path
  encryption_config = {
    provider_key_arn = var.kms_key_id
  }

  eks_managed_node_groups = var.create_node_group ? {
    default = {
      instance_types = [var.eks_node_instance_type]

      min_size     = var.eks_node_min_size
      max_size     = var.eks_node_max_size
      desired_size = var.eks_node_desired_size

      ami_type = var.eks_node_ami_type
      ami_id   = var.eks_node_ami_id

      enable_bootstrap_user_data = true
      pre_bootstrap_user_data = (
        startswith(var.eks_node_ami_type, "AL2_")
        ? var.eks_node_startup_script
        : null
      )
      cloudinit_pre_nodeadm = (
        (startswith(var.eks_node_ami_type, "AL2023_") && var.eks_node_startup_script != null)
        ? [{
          content_type = "text/x-shellscript"
          content      = var.eks_node_startup_script
        }]
        : null
      )

      attach_cluster_primary_security_group = true

      iam_role_path                 = var.iam_role_path
      iam_role_permissions_boundary = var.iam_role_permissions_boundary
    }
  } : {}

  include_oidc_root_ca_thumbprint = false
  custom_oidc_thumbprints         = var.oidc_thumbprints

  enable_cluster_creator_admin_permissions = false

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
}

resource "aws_iam_role_policy" "eks_node_custom_inline" {
  count = var.create && var.create_node_group && var.eks_node_iam_role_policy_json != null ? 1 : 0

  name   = "${var.name}-node-custom-inline"
  role   = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy = var.eks_node_iam_role_policy_json
}

resource "aws_vpc_security_group_ingress_rule" "eks_api_from_vpc" {
  for_each = var.create ? toset(var.cluster_api_ingress_cidr_blocks) : toset([])

  security_group_id = module.eks.cluster_security_group_id
  description       = "Allow EKS API access from internal network"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}
