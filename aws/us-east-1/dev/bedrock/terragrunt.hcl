include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_terragrunt_dir()}/../../../..//modules/aws/bedrock/"
}

dependency "s3" {
  config_path = "../s3/kb_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show", "destroy"]
  mock_outputs = {
    arn    = "arn:aws:s3:::fake-bucket"
    bucket = "fake-bucket"
  }
}

dependency "kb_exec_role" {
  config_path = "../iam_role"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    role_arn  = "arn:aws:iam::123456789012:role/FakeRole"
    role_name = "fake_role_name"
  }
}


locals {
  name       = "${include.parent.locals.global.project}-${include.parent.locals.environment}"
  region     = include.parent.locals.global.aws_region
  account_id = include.parent.locals.account_id
}

inputs = {
  name           = local.name
  kb_description = "Bedrock ECAN Chatbot"
  region         = local.region
  id_account     = local.account_id

  #AWS OpenSearch Serverless related variables
  oass_collection_name              = "${include.parent.locals.global.project}-${include.parent.locals.environment}"
  oass_network_security_policy_name = "chatbot-ecan-pub-net-policy-${include.parent.locals.environment}"
  oass_encryption_policy_name       = "chatbot-ecan-encrypt-policy-${include.parent.locals.environment}"
  oass_data_access_policy_name      = "cbot-ecan-data-access-policy-${include.parent.locals.environment}"


  kb_role_arn   = dependency.kb_exec_role.outputs.role_arn
  kb_role_name  = dependency.kb_exec_role.outputs.role_name
  s3_bucket_arn = dependency.s3.outputs.arn

  vector_index_name      = "${include.parent.locals.global.project}-${include.parent.locals.environment}-default-index"
  vector_field           = "${include.parent.locals.global.project}-${include.parent.locals.environment}-vector"
  kb_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  kb_model_id            = "amazon.titan-embed-text-v2:0"
  kb_configuration_type  = "VECTOR"

  t_account_id  = include.parent.locals.account_id
  t_external_id = include.parent.locals.global.external_id
  t_tf_role     = include.parent.locals.global.trust_role
}
