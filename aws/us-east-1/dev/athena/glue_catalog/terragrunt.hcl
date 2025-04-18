include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/glue-database_0.1.1"
}

locals {
  global   = include.root.locals.global
  app_name = local.global.app_name
  project  = local.global.project
}

inputs = {
  name        = "${local.app_name}-gluej"
  db_name     = "${local.app_name}"
  description = "Glue database for P2P Athena queries"
  lf_tags = {
    project = ["poc-ia-providersp2p-la"]  
  }
}
