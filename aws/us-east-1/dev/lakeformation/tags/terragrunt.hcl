include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//modules/dlake_permissions?ref=aws/lakeformation_0.1.0"

}


dependency "iam_oidc_role" {
  config_path = "../../athena/iam_role"
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
          values = [local.project]
        }
      }
    }

    table_access = {
      principal     = dependency.iam_oidc_role.outputs.role_arn
      permissions   = ["SELECT", "INSERT", "DROP", "DESCRIBE"]
      resource_type = "TABLE"
      lf_tags = {
        project = {
          values = [local.project]
        }
      }
    }
  }
}