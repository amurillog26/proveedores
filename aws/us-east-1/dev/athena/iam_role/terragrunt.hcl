include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/iamrole_6.1.0"
}

dependency "output_bucket" {
  config_path = "../../s3/output_buckets/output_bucket"
}

dependency "athena_results_bucket" {
  config_path = "../../s3/output_buckets/athena_results_bucket"

  mock_outputs = {
    athena_results_bucket_output = "arn:aws:s3:::mock-athena-results"
  }
}

locals {
  global                = include.parent.locals.global
  template_file_path    = "${get_terragrunt_dir()}/policies/policy.tpl"
  assume_role_file_path = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  app_name              = local.global.app_name
}

inputs = {
  name                  = "${local.app_name}-athena-role"
  role_description      = "IAM role for Athena to access a bucket to get data sources and write queries within another bucket"
  assume_role_file_path = local.assume_role_file_path

  iam_policies = {
    access_csv_and_results = {
      name               = "access_csv_and_results"
      description        = "P2P PoC. Allow athena to get csv files from a bucket and store queries within another bucket"
      template_file_path = local.template_file_path
      template_vars = {
        vars = {
          csv_bucket_arn     = dependency.output_bucket.outputs.arn
          results_bucket_arn = dependency.athena_results_bucket.outputs.arn
        }
      }
      use_custom_name = false
    }
  }
}
