include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/eventbridge/aws?version=4.1.0"
}

dependency "lambda_function" {
  config_path = "../lambda_function"
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    lambda_function_name = "MOCK-DEMO-API-LAMBDA"
    lambda_function_arn  = "arn:aws:lambda:test-region-1:xxxxxxxxxxxx:function:mock-lambda"
  }
}

inputs = {
  create_bus              = false
  attach_lambda_policy    = true
  append_schedule_postfix = false
  role_name               = "${dependency.lambda_function.outputs.lambda_function_name}-INVOKE-ROLE"
  lambda_target_arns = [dependency.lambda_function.outputs.lambda_function_arn]
  schedules = {
    "${values.name}" = {
      group_name          = "default"
      description         = "Trigger for DEMO API LAMBDA (daily)"
      schedule_expression = "cron(0 7 * * ? *)"
      timezone            = "Asia/Shanghai"
      arn                 = dependency.lambda_function.outputs.lambda_function_arn
      retry_policy = {
        maximum_event_age_in_seconds = 86400 # 24 hours
        maximum_retry_attempts = 2
      }
    }
  }
}
