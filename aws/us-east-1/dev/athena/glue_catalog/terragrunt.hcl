include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../../tf-modules/glue-database"
}

locals {
  global   = include.root.locals.global
  app_name = "io-la-dev-providerp2p"
  project  = local.global.project
}

inputs = {
  name        = "${local.app_name}-gluej"
  db_name     = "${local.app_name}"
  description = "Glue database for P2P Athena queries"
  lf_tags = {
    project1 = "poc-ia-providersp2p-la"
  }
}
