include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/eks-pod-identity/aws?version=1.12.1"
}

inputs = {
  name                 = values.name
  attach_custom_policy = true
  use_name_prefix      = false
  policy_statements = [
    {
      sid = "SecretsManager"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = values.common_secrets_arns
    }
  ]
  associations = {
    sa = {
      cluster_name    = values.pod_identity_association.cluster_name
      namespace       = values.pod_identity_association.namespace
      service_account = values.pod_identity_association.service_account
    }
  }

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}