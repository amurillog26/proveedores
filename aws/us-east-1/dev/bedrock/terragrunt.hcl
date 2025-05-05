include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../tf-modules/bedrock/"
}


locals {
  global         = include.root.locals.global
  app_name       = local.global.app_name
  account_id     = local.global.account_id
  external_id    = local.global.external_id
  trust_role     = local.global.trust_role
  collection_name = "${local.app_name}-kb-coll"
  vector_index_name = "${local.app_name}-kb-idx"
}

inputs = {
  # Basic information
  name                = "${local.app_name}-kb"
  kb_description      = "Knowledge base for P2P vendor financial inquiries"
  kb_configuration_type = "VECTOR"
  
  # IAM roles - Using hardcoded values for now until IAM role is created
  kb_role_arn         = "arn:aws:iam::${local.account_id}:role/${local.app_name}-bedrock-kb-role"
  kb_role_name        = "${local.app_name}-bedrock-kb-role"
  
  # S3 bucket for data source - Using the app_name to construct the bucket ARN
  s3_bucket_arn       = "arn:aws:s3:::${local.app_name}-kb-input"
  s3_inclusion_prefixes = []
  
  # OpenSearch Serverless configuration
  oass_collection_name = local.collection_name
  oass_collection_desc = "OpenSearch collection for P2P Bedrock KB"
  oass_collection_type = "VECTORSEARCH"
  
  # Security policies - SHORTENED NAMES to be under 32 characters
  oass_network_security_policy_name = "${local.app_name}-network-policy"
  oass_encryption_policy_name = "${local.app_name}-encrypt-policy"
  oass_data_access_policy_name = "${local.app_name}-access-policy"
  oass_data_access_policy_desc = "Data access policy for P2P Bedrock KB"
  
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
