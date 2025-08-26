include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/route53/aws//modules/records?version=5.0.0"
}

inputs = {
  zone_name = values.zone_name
  records   = values.records
}