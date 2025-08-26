include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/secrets-manager/aws?version=1.3.1"
}

inputs = {
  name                    = values.name
  description             = values.description
  recovery_window_in_days = 7
  ignore_secret_changes   = values.ignore_secret_changes
  secret_string           = values.secret_string

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}