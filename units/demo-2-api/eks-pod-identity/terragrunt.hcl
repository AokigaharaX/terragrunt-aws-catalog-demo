include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "secrets_manager" {
  config_path = "../secrets-manager"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    secret_arn = "arn:aws:secretsmanager:ap-southeast-1:xxxxx:secret:SOME-FAKE-SECRET"
  }
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
      resources = concat(
        ["${dependency.secrets_manager.outputs.secret_arn}"],
        values.common_secrets_arns
      )
    }
  ]
  associations = {
    sa = {
      cluster_name    = values.pod-identity-association.cluster_name
      namespace       = values.pod-identity-association.namespace
      service_account = values.pod-identity-association.service_account
    }
  }

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}