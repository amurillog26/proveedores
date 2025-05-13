include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//modules/dlake_permissions?ref=aws/lakeformation_1.0.0"
}

dependency "iam_oidc_role" {
  config_path = "../../athena/iam_role"
  mock_outputs = {
    role_arn = "arn:aws:iam::123456789012:role/mock-role"
  }
}

dependency "lf_tags" {
  config_path = "../tags"
  mock_outputs = {}
}

dependency "glue_catalog" {
  config_path = "../../athena/glue_catalog"
  mock_outputs = {}
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
          values = ["poc-ia-providersp2p-la"]
        }
      }
    },
    
    table_access = {
      principal     = dependency.iam_oidc_role.outputs.role_arn
      permissions   = ["SELECT", "INSERT", "DROP", "DESCRIBE"]
      resource_type = "TABLE"
      lf_tags = {
        project = {
          values = ["poc-ia-providersp2p-la"]
        }
      }
    }
  }
}
