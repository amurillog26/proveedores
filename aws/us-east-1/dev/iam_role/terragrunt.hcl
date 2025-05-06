include "root" {
  path   = find_in_parent_folders()  # Esto irá directamente al archivo raíz
  expose = true
}

dependency "s3" {
  config_path = "../s3/kb_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show", "destroy"]
  mock_outputs = {
    arn    = "arn:aws:s3:::fake-bucket"
    bucket = "fake-bucket"
  }
}

terraform {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git///?ref=aws/iamrole_6.1.0"
}

locals {
  assume_role_file_path = "${get_terragrunt_dir()}/policies/assume-role.tpl"
  policy_file_path      = "${get_terragrunt_dir()}/policies/kb-policy.tpl"  # Cambiado a kb-policy.tpl

  region     = include.root.locals.global.aws_region
  account_id = include.root.locals.account_id
}

inputs = {
  ## Role Attributes ##
  name             = "AmazonBedrockExecutionRoleForKnowledgeBase_argen7"
  use_custom_name  = true
  role_description = "IAM Role for execution KB Bedrock"

  assume_role_file_path = local.assume_role_file_path
  template_vars = {
    vars = {
      aws_service = "bedrock.amazonaws.com"
      region      = local.region
      account_id  = local.account_id
    }
  }

  iam_policies = {
    default = {
      name               = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_argen7"
      use_custom_name    = true
      description        = "Permissions for Bedrock for model logging."
      template_file_path = local.policy_file_path
      template_vars = {
        vars = {
          region     = local.region
          account_id = local.account_id
          s3_arn     = dependency.s3.outputs.arn
          aoss_col   = "bedrock-knowledge-base-*"
          project    = include.root.locals.global.project  # Cambiado de parent a root
          kms_alias = jsonencode([
            "alias/*-encrypt"
          ])
        }
      }
    }
  }
}

outputs = {
  role_arn  = aws_iam_role.this.arn
  role_name = aws_iam_role.this.name
}
