
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/sagemaker-notebook_2.0.0"
}

dependency "iam_role" {
  config_path                             = "../iam_role"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]

  mock_outputs = {
    role_arn  = "arn:aws:iam::123456789101:role/service-role/fake-role"
    role_name = "fake-iam-role"
  }

}

dependency "sm_security_group" {
  config_path = "../sg"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    id = "fake-security_group-id"
  }
}

inputs = {
  name                 = "providerp2p-data-cleansing"
  notebook_name        = "notebook_to_transform"
  instance_type        = "ml.t3.medium"
  volume_size          = "5"
  notebook_kernel      = "conda_tensorflow2_p310"
  instance_custom_role = true
  role_arn             = dependency.iam_role.outputs.role_arn
  role_name            = dependency.iam_role.outputs.role_name
  security_groups      = [dependency.sm_security_group.outputs.id]
  subnet_id            = "subnet-07cfe132a5d6648b6"
  s3_notebook_path     = "s3://lhlanonp-providerp2p-query/notebooks"
}


