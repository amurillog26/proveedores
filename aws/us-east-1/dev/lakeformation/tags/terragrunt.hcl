include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/lakeformation_0.1.0"

}

inputs = {
  lf_tags = {
    project     = ["poc-ia-providersp2p-la"]
    environment = ["dev"]
  }
}