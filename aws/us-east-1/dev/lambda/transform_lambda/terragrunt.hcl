include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/lambda-function_1.4.0"
}

locals {
  extra_atlantis_dependencies = [
    "${get_terragrunt_dir()}/policies/assume-role.tpl",
    "${get_terragrunt_dir()}/policies/lambda-policy.tpl"
  ]
}

# Dependencies on S3 buckets
dependency "input_bucket" {
  config_path = "${get_terragrunt_dir()}/../../s3/input_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    arn = "fake-bucket_arn"
    id  = "fake-bucket-id"
  }
}

dependency "output_bucket" {
  config_path = "${get_terragrunt_dir()}/../../s3/output_buckets/output_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    arn = "fake-output-bucket_arn"
    id  = "fake-output-bucket-id"
  }
}

inputs = {
  # Basic Lambda configuration
  name        = "data-transform-lambda"
  description = "Lambda function for transforming and outputting data"
  
  # Lambda code configuration
  source_code_path = "${get_terragrunt_dir()}/src"
  runtime_path     = "node_modules" 
  buildcmd         = "npm install"
  excludes         = ["**/.git/**", "**/.idea/**", "**/node_modules/.bin/**"]
  
  # Handler and runtime settings
  handler_name = "index.handler"
  lambda_settings = {
    runtime       = "nodejs18.x"
    architectures = ["x86_64"]
    timeout       = 120
    memory_size   = 512
  }
  
  # Environment variables
  env_variables = {
    ENV             = include.root.locals.environment
    INPUT_BUCKET    = dependency.input_bucket.outputs.id
    OUTPUT_BUCKET   = dependency.output_bucket.outputs.id
    LOG_LEVEL       = "info"
  }
  
  # IAM configuration with policies
  policy_file_name = "${get_terragrunt_dir()}/policies/lambda-policy.tpl"
  policy_vars = {
    vars = {
      input_bucket_arn  = dependency.input_bucket.outputs.arn
      output_bucket_arn = dependency.output_bucket.outputs.arn
    }
  }
  
  assume_role_file_name = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  
  # CloudWatch logs configuration
  cloudwatch_log_retention_in_days = 30
  
  # KMS encryption - Using SSM parameters
  ssm_kms_cwlogs = "/kms/cwlogs/arn"
  ssm_kms_lmb    = "/kms/lambda/arn"
  
  # Additional configuration
  ephemeral_storage = 1024  # 1GB for more processing power
  publish           = true
  
  # Enable X-Ray tracing
  tracing_mode = "Active"
  
  # Layers if needed
  layers = [
    # "arn:aws:lambda:${include.root.locals.aws_region}:${include.root.locals.aws_account_id}:layer:common-layer:1"
  ]
}
