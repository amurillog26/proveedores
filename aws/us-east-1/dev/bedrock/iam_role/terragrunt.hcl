include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//aws/iam_role?ref=aws/iam_role_0.4.0"
}

locals {
  global         = include.root.locals.global
  app_name       = local.global.app_name
  collection_name = "${local.app_name}-bedrock-collection"
}

inputs = {
  name                   = "${local.app_name}-bedrock-kb-role"
  description            = "IAM role for Bedrock Knowledge Base"
  assume_role_file_path  = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  
  iam_policies = {
    kb_policy = {
      name               = "${local.app_name}-bedrock-kb-policy"
      description        = "Policy for Bedrock Knowledge Base permissions"
      template_file_path = "${get_terragrunt_dir()}/policies/kb-policy.tpl"
      template_vars = {
        vars = {
          s3_bucket_arn         = "arn:aws:s3:::${local.app_name}-kb-input"
          opensearch_collection = "arn:aws:aoss:us-east-1:*:collection/${local.collection_name}"
          opensearch_index      = "arn:aws:aoss:us-east-1:*:collection/${local.collection_name}/*"
        }
      }
    }
  }
}
