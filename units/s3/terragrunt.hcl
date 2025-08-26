include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=5.2.0"
}

inputs = {
  bucket        = values.bucket_name
  force_destroy = values.force_destroy

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}