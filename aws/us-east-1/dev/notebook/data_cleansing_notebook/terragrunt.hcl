include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/sagemaker-notebook_2.0.0"
}

dependency "iam_role" {
  config_path = "../iam_role"
}

inputs = {
  name            = "providerp2p-data-cleansing"
  notebook_name   = "notebook_to_transform"
  instance_type   = "ml.t3.medium"
  volume_size     = 5
  notebook_kernel  = "conda_tensorflow2_p310"
  role_name = dependency.iam_role.outputs.role_name
  s3_notebook_path = "s3://lhlanonp-providerp2p-query/notebooks"
}


