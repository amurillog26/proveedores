include "root" {
  path   = find_in_parent_folders("dev/terragrunt.hcl")
  expose = true
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//aws/iam_role?ref=aws/iam_role_0.4.0"
}

inputs = {
  name                   = "p2p-bedrock-iam"
  assume_role_file_name = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  policy_file_name       = "${get_terragrunt_dir()}/policies/policy.tpl"

  policy_vars = {
    lambda_function_arn   = "arn:aws:lambda:us-east-1:123456789012:function:mock-athena-query"
    s3_bucket_arn         = "arn:aws:s3:::mock-kb-bucket"
    opensearch_collection = "arn:aws:aoss:us-east-1:123456789012:collection/p2p-bedrock-collection"
    opensearch_index      = "arn:aws:aoss:us-east-1:123456789012:index/p2p-bedrock-collection/*"
  }
}

