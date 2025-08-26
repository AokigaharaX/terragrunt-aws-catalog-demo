include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "./module"
}

inputs = {
  tg_name           = values.name
  vpc_id            = values.vpc_id
  health_check_path = values.health_check_path
  listener_arn      = values.listener_arn
  priority          = values.priority
  host_headers      = values.host_headers

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}