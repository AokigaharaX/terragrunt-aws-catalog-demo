include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/ecr/aws?version=2.4.0"
}

inputs = {
  repository_name = values.repo_name
  repository_type = "private"

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 10,
        description  = "Keep a maximum of 30 copies for images with tag-prefix \"develop\".",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["develop"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 20,
        description  = "Keep a maximum of 30 copies for images with tag-prefix \"feature\".",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["feature"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 30,
        description  = "Keep a maximum of 30 copies for images with tag-prefix \"pre_release\".",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["pre_release"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 40,
        description  = " Keep only one untagged image, expire all others.",
        selection = {
          tagStatus     = "untagged",
          countType     = "imageCountMoreThan",
          countNumber   = 1
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}