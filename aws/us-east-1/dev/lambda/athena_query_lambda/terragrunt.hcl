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

dependency "athena_results_bucket" {
  config_path = "../../s3/athena_results_bucket"
  mock_outputs = {
    bucket = "mock-athena-results"
  }
}

dependency "glue_database" {
  config_path = "../../athena/glue_catalog"
  mock_outputs = {
    db_name = "mock-glue-database"
  }
}

locals {
  global                = include.parent.locals.global
  policy_file_path      = "${get_terragrunt_dir()}/policies/lambda-policy.tpl"
  assume_role_file_path = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  app_name              = local.global.app_name
  account_id            = include.parent.locals.account_id
}

inputs = {
  # Configuración básica de Lambda
  name        = "${local.app_name}-p2pMax"
  description = "Lambda function for P2P Procurement Bedrock Agent integration"
  
  # Usar archivo ZIP con código Python
  filename = "${get_terragrunt_dir()}/function.zip"
  
  # Desactivar la generación del código fuente
  source_code_path = null
  
  # Deshabilitar el uso de S3 para el código
  from_s3_object = false
  
  # Handler y configuración del runtime para Python
  handler_name = "p2pMax.lambda_handler"
  lambda_settings = {
    runtime       = "python3.12"
    architectures = ["x86_64"]
    timeout       = 120
    memory_size   = 512
  }
  
  # Agregar el Layer AWSSDKPandas para Python
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python312:16"]
  
  # Variables de entorno necesarias para el código
  env_variables = {
    ENV             = "dev"
    KB_BUCKET       = dependency.kb_bucket.outputs.bucket
    QUERY_BUCKET    = dependency.query_bucket.outputs.bucket
    INPUT_BUCKET    = dependency.input_bucket.outputs.bucket
    ATHENA_DATABASE = dependency.glue_database.outputs.db_name
    S3_OUTPUT       = "s3://${dependency.athena_results_bucket.outputs.bucket}/athena-results/"
    REGION          = local.global.aws_region
    LOG_LEVEL       = "INFO"
  }
  
  # Usar las claves KMS reales
  kms_lmb_arn = "arn:aws:kms:us-east-1:745315529340:key/mrk-23695674f5234cee877cd8358b7187bc"
  
  # Configuración IAM - Permisos ampliados
  policy_file_name = local.policy_file_path
  policy_vars = {
    vars = {
      input_bucket_arn    = "arn:aws:s3:::${dependency.input_bucket.outputs.bucket}"
      kb_bucket_arn       = "arn:aws:s3:::${dependency.kb_bucket.outputs.bucket}"
      query_bucket_arn    = "arn:aws:s3:::${dependency.query_bucket.outputs.bucket}"
      athena_results_arn  = "arn:aws:s3:::${dependency.athena_results_bucket.outputs.bucket}"
      kms_key_arn         = "arn:aws:kms:us-east-1:745315529340:key/mrk-23695674f5234cee877cd8358b7187bc"
      account_id          = local.account_id
      region              = local.global.aws_region
    }
  }
  
  assume_role_file_name = local.assume_role_file_path
  
  # Configuración de logs de CloudWatch
  cloudwatch_log_retention_in_days = 30
  
  # Event triggers
  allowed_triggers = {
    BedrockAgent = {
      service    = "bedrock"
      source_arn = "arn:aws:bedrock:${local.global.aws_region}:${local.account_id}:agent/*"
    }
  }
  
  # Configuración adicional
  ephemeral_storage = 512  # MB
  publish           = true
  
  # Habilitar X-Ray tracing
  tracing_mode = "Active"
  
  # Agregar política de recursos para permitir que Bedrock invoque la función
  resource_policy_statements = {
    allow-bedrock-agent = {
      effect    = "Allow"
      actions   = ["lambda:InvokeFunction"]
      principals = [{
        type        = "Service"
        identifiers = ["bedrock.amazonaws.com"]
      }]
      condition = {
        ArnLike = {
          "AWS:SourceArn" = "arn:aws:bedrock:${local.global.aws_region}:${local.account_id}:agent/*"
        }
      }
    }
  }
}
