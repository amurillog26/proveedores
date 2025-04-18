include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//modules/tags?ref=aws/lakeformation_0.1.0"
}

locals {
  global  = include.root.locals.global
  project = local.global.project
}

inputs = {
  lf_tags = {
    project = [local.project, "poc-ia-providersp2p-la"]
  }
}
