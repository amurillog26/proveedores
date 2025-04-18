include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//modules/dlake_permissions?ref=aws/lakeformation_0.1.0"
}

# Dependencia del rol IAM
dependency "iam_oidc_role" {
  config_path = "../../athena/iam_role"
}

# Dependencia de las tags
dependency "lf_tags" {
  config_path = "../tags"
  skip_outputs = true
}

# Si los permisos dependen del catálogo Glue
dependency "glue_catalog" {
  config_path = "../../athena/glue_catalog"
  skip_outputs = true
}

locals {
  global  = include.root.locals.global
  project = local.global.project
}

inputs = {
  catalog_permissions = {
    database_access = {
      principal     = dependency.iam_oidc_role.outputs.role_arn
      permissions   = ["CREATE_TABLE", "ALTER", "DROP", "DESCRIBE"]
      resource_type = "DATABASE"
      lf_tags = {
        project = {
          values = ["poc-ia-providersp2p-la"]  # Esto es correcto como array
        }
      }
    }

    table_access = {
      principal     = dependency.iam_oidc_role.outputs.role_arn
      permissions   = ["SELECT", "INSERT", "DROP", "DESCRIBE"]
      resource_type = "TABLE"
      lf_tags = {
        project = {
          values = ["poc-ia-providersp2p-la"]  # Esto es correcto como array
        }
      }
    }
  }
  # Si tienes s3_location_permissions, mantenlos igual
}
