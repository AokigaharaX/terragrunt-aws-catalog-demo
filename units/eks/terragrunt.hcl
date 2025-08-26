include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=21.0.3"
}

inputs = {
  name               = values.cluster_name
  kubernetes_version = values.kubernetes_version

  enable_irsa                              = false
  enable_cluster_creator_admin_permissions = true
  cloudwatch_log_group_retention_in_days   = 30

  compute_config = {
    enabled = true
    node_pools = [
      "general-purpose",
      "system"
    ]
    node_role_arn = values.node_role_arn
  }

  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  create_kms_key = false
  encryption_config = {
    provider_key_arn = values.cluster_encryption_key_arn
    resources = ["secrets"]
  }

  create_iam_role      = false
  create_node_iam_role = false
  iam_role_arn         = values.cluster_iam_role_arn

  vpc_id     = values.vpc_id
  subnet_ids = values.subnet_ids

  create_security_group         = false
  create_node_security_group    = false
  endpoint_private_access       = true
  endpoint_public_access        = false
  endpoint_public_access_cidrs = []
  additional_security_group_ids = values.cluster_additional_sg_ids

  addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {}
    aws-efs-csi-driver = {
      pod_identity_association = [
        {
          role_arn        = "arn:aws:iam::${get_aws_account_id()}:role/AWS-EFS-CSI-DRIVER-ROLE"
          service_account = "efs-csi-controller-sa"
        }
      ]
    }
  }

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}