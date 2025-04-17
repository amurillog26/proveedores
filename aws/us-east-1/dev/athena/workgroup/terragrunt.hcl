include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  global   = include.root.locals.global
  app_name = local.global.app_name
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/athena-workgroup_0.1.2"
}


dependency "athena_results_bucket" {
  config_path = "../../s3/athena_results_bucket"

  mock_outputs = {
    athena_results_bucket_output = "mock-athena_results_bucket-output"
  }
}

dependency "glue_database" {
  config_path = "../glue_catalog"
  mock_outputs = {
    glue_database_output = "mock-glue_database-output"
  }
}


inputs = {
  name                            = local.app_name
  workgroup_name                  = local.app_name
  workgroup_custom_name           = true
  description                     = "Workgroup for ${local.app_name} queries"
  artifacts_bucket                = dependency.athena_results_bucket.outputs.bucket
  bucket_prefix                   = "athena/"
  enforce_workgroup_configuration = true
  cloudwatch_enabled              = true
  engine_version                  = "AUTO"

}

