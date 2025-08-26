include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/eks-pod-identity/aws?version=1.12.1"
}

inputs = {
  name                      = values.name
  attach_aws_efs_csi_policy = true
  aws_efs_csi_policy_name   = values.policy_name
  use_name_prefix           = false

  associations = {
    sa = {
      cluster_name    = values.eks_cluster_name
      namespace       = "kube-system"
      service_account = "efs-csi-controller-sa"
    }
  }

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}

