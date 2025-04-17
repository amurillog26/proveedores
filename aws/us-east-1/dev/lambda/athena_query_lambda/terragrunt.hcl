include "parent" {
  path   = find_in_parent_folders()
  expose = true
}
terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/lambda-function_1.4.0"
}
dependency "kb_bucket" {
  config_path = "../../s3/kb_bucket"
  mock_outputs = {
    bucket = "mock-kb"
  }
}
dependency "query_bucket" {
  config_path = "../../s3/query_bucket"
  mock_outputs = {
    bucket = "mock-query"
  }
}
dependency "input_bucket" {
  config_path = "../../s3/input_bucket"
  mock_outputs = {
    bucket = "mock-input"
  }
}
locals {
  global                = include.parent.locals.global
  policy_file_path      = "${get_terragrunt_dir()}/policies/lambda-policy.tpl"
  assume_role_file_path = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  app_name              = local.global.app_name
}
inputs = {
  # Basic Lambda configuration
  name        = "${local.app_name}-athena-query-lambda"
  description = "Lambda function for processing Athena queries"
  
  # Usar un archivo ZIP precompilado en lugar de generar uno
  # Necesitas proporcionar un archivo function.zip o archivo ZIP preexistente
  filename = "function.zip"  
  
  # Desactivar la generación del código fuente
  source_code_path = null
  
  # Deshabilitar el uso de S3 para el código
  from_s3_object = false
  
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
    KB_BUCKET       = dependency.kb_bucket.outputs.bucket
    QUERY_BUCKET    = dependency.query_bucket.outputs.bucket
    INPUT_BUCKET    = dependency.input_bucket.outputs.bucket
    LOG_LEVEL       = "info"
  }
  
  # FUNDAMENTAL: Desactivar completamente el uso de KMS
  use_kms = false  # Si el módulo soporta esta variable
  
  # Configuraciones adicionales para evitar problemas con KMS
  kms_cwlogs_arn = " "  # Espacio en blanco en lugar de cadena vacía
  kms_lmb_arn = " "     # Espacio en blanco en lugar de cadena vacía
  
  # IAM configuration
  policy_file_name = local.policy_file_path
  policy_vars = {
    vars = {
      input_bucket_arn  = "arn:aws:s3:::${dependency.input_bucket.outputs.bucket}"
      kb_bucket_arn     = "arn:aws:s3:::${dependency.kb_bucket.outputs.bucket}"
      query_bucket_arn  = "arn:aws:s3:::${dependency.query_bucket.outputs.bucket}"
      # Para resolver el problema con kms_key_arn en tu plantilla
      kms_key_arn       = "arn:aws:kms:us-east-1:*:key/*"
    }
  }
  
  assume_role_file_name = local.assume_role_file_path
  
  # CloudWatch logs configuration
  cloudwatch_log_retention_in_days = 30
  
  # Event triggers
  allowed_triggers = {
    S3Upload = {
      service    = "s3"
      source_arn = "arn:aws:s3:::${dependency.kb_bucket.outputs.bucket}"
    }
  }
  
  # Additional configuration
  ephemeral_storage = 512  # MB
  publish           = true
  
  # Enable X-Ray tracing
  tracing_mode = "Active"
}