include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/sagemaker-notebook_2.0.0"
}

inputs = {
  name          = "providerp2p-data-cleansing"
}


