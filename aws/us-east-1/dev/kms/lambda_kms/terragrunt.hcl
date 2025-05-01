include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/kms_1.3.3"
}

locals {
  global = include.parent.locals.global
}

inputs = {
  name        = "${local.global.app_name}-lambda-kms"
  description = "KMS key for Lambda environment variables encryption"
  
  # Configuración básica
  key_enabled               = true
  enable_key_rotation       = true
  deletion_window_in_days   = 7
  custom_alias_name         = "alias/${local.global.app_name}-lambda"
  
  # Crear parámetro SSM
  create_ssm_param           = true
  custom_ssm_alias_arn_name  = "def-kms-lambda"
  
  # Política de clave simplificada
  # Usando servicios AWS en lugar de roles específicos
  enable_default_policy      = true
  
  # Política amplia para permitir que los servicios necesarios accedan a la clave
  additional_iam_statements = [
    {
      sid = "AllowLambdaService"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources = ["*"]
      principals = [
        {
          type = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }
      ]
    }
  ]
}
