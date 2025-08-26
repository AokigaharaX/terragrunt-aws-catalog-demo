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

inputs = {
  create_function = false
  create_layer    = true

  layer_name  = "demo-api-lambda-layer-s3"
  description = "S3 lambda layer for demo-api"
  runtime     = "python3.11"
  source_path = [
    {
      path             = "${get_terragrunt_dir()}/scripts/lambda.py",
      pip_requirements = "${get_terragrunt_dir()}/scripts/requirements.txt"
    }
  ]
  store_on_s3 = true
  s3_bucket   = "${dependency.s3.outputs.s3_bucket_id}"
}