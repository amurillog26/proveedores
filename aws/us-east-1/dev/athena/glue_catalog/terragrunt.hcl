include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../../modules/aws/glue-database"
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
    project = "poc-ia-providersp2p-la"
  }
}
