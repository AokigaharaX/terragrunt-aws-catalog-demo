include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/lambda/aws?version=8.0.1"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    s3_bucket_id = "s3-test-package-bucket"
  }
}

dependency "lambda_layer" {
  config_path = "../lambda_layer"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    s3_object = {
      "bucket" = "a-lambda-package-mock"
      "key"    = "builds\\mock-it.zip"
    }
  }
}

dependency "efs" {
  config_path = "../efs"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    arn = "arn:aws:elasticfilesystem:ap-southeast-1:xxxx:file-system/fs-this-is-mock-data"
    access_points = {
      demo = {
        arn = "arn:aws:elasticfilesystem:ap-southeast-1:xxxx:access-point/fsap-this-is-mock-data"
      }
    }
  }
}

inputs = {
  function_name = values.function_name
  description   = values.description
  handler       = values.handler
  runtime       = "python3.11"

  publish = true

  create_package      = false
  s3_existing_package = dependency.lambda_layer.outputs.s3_object

  environment_variables = values.environment_variables

  vpc_subnet_ids         = values.subnets
  vpc_security_group_ids = values.security_group_ids
  attach_network_policy  = true

  file_system_arn              = "${dependency.efs.outputs.access_points["demo"].arn}"
  file_system_local_mount_path = values.mountpoint_path
  attach_policy_statements     = true
  policy_statements = {
    efs = {
      effect = "Allow",
      actions = ["elasticfilesystem:*"],
      resources = ["${dependency.efs.outputs.arn}"]
    }
    secrets-manager = {
      effect = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [values.license_key_secret_arn]
    }
  }

  allowed_triggers = {
    EventBridgeScheduleAny = {
      principal  = "scheduler.amazonaws.com"
      source_arn = "arn:aws:scheduler:${include.env.locals.region}:${get_aws_account_id()}:schedule/default/*"
    }
  }

  timeout = 900

  function_tags = {
    Language = "python"
  }

  tags = merge(
    include.env.locals.common_tags,
    values.tags
  )
}