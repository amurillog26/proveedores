include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/lambda-function_1.4.0"
}

locals {
  # Make sure these extra_atlantis_dependencies paths match your actual file structure
  extra_atlantis_dependencies = [
    "${get_terragrunt_dir()}/policies/assume-role.tpl",
    "${get_terragrunt_dir()}/policies/lambda-policy.tpl"
  ]
}

# Dependency on S3 bucket
dependency "input_bucket" {
  config_path = "${get_parent_terragrunt_dir()}/s3/input_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    arn = "fake-bucket_arn"
    id  = "fake-bucket-id"
  }
}

dependency "output_bucket" {
  config_path = "${get_parent_terragrunt_dir()}/s3/output_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    arn = "fake-output-bucket_arn"
    id  = "fake-output-bucket-id"
  }
}

inputs = {
  # Basic Lambda configuration
  name        = "processor-lambda"
  description = "Lambda function for processing input data"
  
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
    timeout       = 60
    memory_size   = 256
  }
  
  # Environment variables
  env_variables = {
    ENV             = "dev"
    INPUT_BUCKET    = dependency.input_bucket.outputs.id
    OUTPUT_BUCKET   = dependency.output_bucket.outputs.id
    LOG_LEVEL       = "info"
  }
  
  # IAM configuration - create a new role with policies
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
  
  # Event triggers - e.g., triggered by S3 uploads
  allowed_triggers = {
    S3Upload = {
      service    = "s3"
      source_arn = dependency.input_bucket.outputs.arn
    }
  }
  
  # Additional configuration
  ephemeral_storage = 512  # MB
  publish           = true
  
  # Enable X-Ray tracing
  tracing_mode = "Active"
}
