include "root" {
  path   = find_in_parent_folders()
  expose = true
}

#deleting iam role
terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/iamrole_6.1.0"
}

locals {
  extra_atlantis_dependencies = [
    "${get_terragrunt_dir()}/policies/assume-role.tpl",
    "${get_terragrunt_dir()}/policies/custom-policy.tpl"
  ]
}

dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../../s3/input_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    arn = "fake-bucket_arn"
  }

}

inputs = {
  name                  = "providerp2p-role"
  role_description      = "IAM Role for SageMaker Notebook providers PoC"
  assume_role_file_path = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  template_file_path    = "${get_terragrunt_dir()}/policies/custom-policy.tpl"


  template_vars = {
    vars = {
      s3_source_arn = dependency.bucket.outputs.arn
    }


    iam_policies = {
      custom_s3_access = {
        name               = "sagemaker-s3-access"
        description        = "S3 read from input-bucket, write to output-bucket"
        template_file_path = "${get_terragrunt_dir()}/policies/custom-policy.tpl"
        template_vars = {
          vars = {
            input_bucket_arn  = "arn:aws:s3:::lhlanonp-providerp2p-input"
            output_bucket_arn = "arn:aws:s3:::lhlanonp-providerp2p-output"
          }
        }
        use_custom_name = true
      }
    }
  }
}