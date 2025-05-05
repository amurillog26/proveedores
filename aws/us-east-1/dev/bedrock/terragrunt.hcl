include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../../modules/aws/bedrock/"
}

dependency "kb_bucket" {
  config_path = "../s3/kb_bucket"
  mock_outputs = {
    bucket = "providerp2p-kb-input"
    arn    = "arn:aws:s3:::providerp2p-kb-input"
  }
}

locals {
  global            = include.root.locals.global
  app_name          = local.global.app_name
  account_id        = local.global.account_id
  external_id       = local.global.external_id
  trust_role        = local.global.trust_role
  collection_name   = "${local.app_name}-kb-coll"
  vector_index_name = "${local.app_name}-kb-idx"
  
  # Rutas a los archivos de políticas
  assume_role_file_path = "${get_terragrunt_dir()}/iam_role/policies/assume-role.tpl"
  policy_file_path      = "${get_terragrunt_dir()}/iam_role/policies/kb-policy.tpl"
}

inputs = {
  # Información básica
  name                   = "${local.app_name}-kb"
  kb_description         = "Knowledge base for P2P vendor financial inquiries"
  kb_configuration_type  = "VECTOR"
  
  # Configuración del rol IAM - Crear nuevo rol usando templates
  create_iam_role        = true
  assume_role_file_path  = local.assume_role_file_path
  policy_file_path       = local.policy_file_path
  
  # Variables para la plantilla de política
  policy_vars = {
    vars = {
      s3_bucket_arn         = dependency.kb_bucket.outputs.arn
      opensearch_collection = "arn:aws:aoss:us-east-1:*:collection/${local.collection_name}"
      opensearch_index      = "arn:aws:aoss:us-east-1:*:collection/${local.collection_name}/*"
    }
  }
  
  # Configuración del bucket S3
  s3_bucket_arn          = dependency.kb_bucket.outputs.arn
  s3_inclusion_prefixes  = []
  
  # Configuración de OpenSearch Serverless
  oass_collection_name   = local.collection_name
  oass_collection_desc   = "OpenSearch collection for P2P Bedrock KB"
  oass_collection_type   = "VECTORSEARCH"
  
  # Políticas de seguridad - nombres abreviados para estar por debajo de 32 caracteres
  oass_network_security_policy_name = "${local.app_name}-network-policy"
  oass_encryption_policy_name       = "${local.app_name}-encrypt-policy"
  oass_data_access_policy_name      = "${local.app_name}-access-policy"
  oass_data_access_policy_desc      = "Data access policy for P2P Bedrock KB"
  
  # Configuración del vector
  vector_index_name = local.vector_index_name
  vector_field      = "${local.collection_name}-vector"
  metadata_field    = "AMAZON_BEDROCK_METADATA"
  text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
  
  # Modelo de embedding
  kb_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  kb_model_id            = "amazon.titan-embed-text-v2"
  
  # Configuración del proveedor OpenSearch
  t_tf_role     = local.trust_role
  t_account_id  = local.account_id
  t_external_id = local.external_id
}
