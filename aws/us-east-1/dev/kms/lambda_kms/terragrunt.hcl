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
  
  # Configuración básica de la clave KMS
  key_enabled               = true
  enable_key_rotation       = true
  deletion_window_in_days   = 7
  custom_alias_name         = "alias/${local.global.app_name}-lambda"
  
  # Crear parámetro SSM para almacenar el ARN de la clave
  create_ssm_param           = true
  custom_ssm_alias_arn_name  = "def-kms-lambda"
  
  # Política de la clave
  enable_default_policy      = true
  key_users = [
    "arn:aws:iam::${local.global.account_id}:role/${local.global.app_name}-athena-query-lambda"
  ]
  
  # Administradores de la clave
  key_administrators = [
    "arn:aws:iam::${local.global.account_id}:role/Admin"
  ]
}
