include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::https://gitlab.com/holcim-adc/americas-core/tools/tf-modules.git//?ref=aws/iamrole_6.0.1"
}

dependency "s3" {
  config_path = "../s3/kb_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show", "destroy"]
  mock_outputs = {
    arn    = "arn:aws:s3:::fake-bucket"
    bucket = "fake-bucket"
  }
}

inputs = {
  use_custom_name       = true
  name                  = "${include.parent.inputs.namespace}-${include.parent.inputs.project}-${include.parent.inputs.environment}-bedrock"
  role_description      = "IAM Role for ${include.parent.inputs.project} bedrock."
  assume_role_file_path = "${get_terragrunt_dir()}/assume-role.json"
  template_vars = {
    vars = {
      aws_service = "bedrock"
      aws_region  = include.parent.locals.global.aws_region
      account_id  = include.parent.locals.account_id
    }
  }

  # policies_arn = [
  #   "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  #   "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  # ]

  iam_policies = {
    allow-bedrock-policy = {
      name               = "${include.parent.inputs.namespace}-${include.parent.inputs.project}-${include.parent.inputs.environment}-bedrock-policy"
      description        = "Allow bedrock interactions."
      template_file_path = "${get_terragrunt_dir()}/allow-bedrock.json"
      use_custom_name    = true
      template_vars = {
        vars = {
          aws_region    = include.parent.locals.global.aws_region
          account_id    = include.parent.locals.account_id
          s3_bucket_arn = dependency.s3.outputs.arn
        }
      }
    }
  }
}
