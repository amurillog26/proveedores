include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_repo_root()}/tf-modules/bedrock"
}

dependency "lambda_function" {
  config_path = "../lambda/athena_query_lambda"

  mock_outputs = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:mock-athena-query"
  }
}

dependency "kb_bucket" {
  config_path = "../s3/kb_bucket"

  mock_outputs = {
    bucket = "mock-kb-bucket"
    arn    = "arn:aws:s3:::mock-kb-bucket"
  }
}

dependency "iam_roles" {
  config_path = "./iam_role"

  mock_outputs = {
    kb_role_arn    = "arn:aws:iam::123456789012:role/mock-kb-role"
    kb_role_name   = "mock-kb-role"
    agent_role_arn = "arn:aws:iam::123456789012:role/mock-agent-role"
  }
}

locals {
  global       = include.root.locals.global
  app_name     = local.global.app_name
  account_id   = local.global.account_id
  external_id  = local.global.external_id
  trust_role   = local.global.trust_role
  collection_name = "${local.app_name}-bedrock-collection"
  vector_index_name = "${local.app_name}-kb-index"
}

inputs = {
  # Basic information
  name                = "${local.app_name}-kb"
  kb_description      = "Knowledge base for P2P vendor financial inquiries"
  kb_configuration_type = "VECTOR"
  
  # IAM roles
  kb_role_arn         = dependency.iam_roles.outputs.kb_role_arn
  kb_role_name        = dependency.iam_roles.outputs.kb_role_name
  
  # S3 bucket for data source
  s3_bucket_arn       = dependency.kb_bucket.outputs.arn
  s3_inclusion_prefixes = []  # Add prefixes if needed
  
  # OpenSearch Serverless configuration
  oass_collection_name = local.collection_name
  oass_collection_desc = "OpenSearch collection for P2P Bedrock Knowledge Base"
  oass_collection_type = "VECTORSEARCH"
  
  # Security policies
  oass_network_security_policy_name = "${local.collection_name}-network-policy"
  oass_encryption_policy_name = "${local.collection_name}-encryption-policy"
  oass_data_access_policy_name = "${local.collection_name}-access-policy"
  oass_data_access_policy_desc = "Data access policy for P2P Bedrock Knowledge Base"
  
  # Vector configuration
  vector_index_name = local.vector_index_name
  vector_field = "${local.collection_name}-vector"
  metadata_field = "AMAZON_BEDROCK_METADATA"
  text_field = "AMAZON_BEDROCK_TEXT_CHUNK"
  
  # Embedding model
  kb_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  kb_model_id = "amazon.titan-embed-text-v2"
  
  # OpenSearch provider configuration
  t_tf_role = local.trust_role
  t_account_id = local.account_id
  t_external_id = local.external_id
}
