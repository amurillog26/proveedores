include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//modules/tags?ref=aws/lakeformation_1.0.0"
}

locals {
  global  = include.root.locals.global
  project = local.global.project
}

# inputs = {
#   lf_tags = {
#     project = ["poc-ia-providersp2p-la"]
#   }
  
#   enable_admins = true
#   additional_principal_sso = ""
#   lf_tag_key_pair = "*"
#   additional_principal_sso_lf_tag_key_pair = "*"
# }
