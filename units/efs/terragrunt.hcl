include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/efs/aws?version=1.8.0"
}

inputs = {
  name                             = values.name
  encrypted                        = true
  attach_policy                    = false
  mount_targets                    = values.mount_target
  security_group_description       = "EFS security group for ${values.name}"
  security_group_vpc_id            = values.security_group_vpc_id
  security_group_rules             = values.security_group_rules
  access_points                    = values.access_points
  enable_backup_policy             = true
  create_replication_configuration = false
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}