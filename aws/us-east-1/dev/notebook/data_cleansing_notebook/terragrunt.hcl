include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/sagemaker-notebook_2.0.0"
}

inputs = {
  name          = "providerp2p-data-cleansing"
  instance_type   = "ml.t3.medium"
  notebook_name    = "cleansing"
  notebook_kernel  = "conda_tensorflow2_p310"
  instance_type   = "ml.t3.medium"
  volume_size     = "5"
}


