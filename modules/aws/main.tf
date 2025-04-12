module "this" {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//?ref=null/tagging_0.3.0"
}

module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.14"

  create_agent             = true
  create_kb                = true
  create_guardrails        = true
  create_agent_alias       = true
  create_ag                = true

  foundation_model         = var.foundation_model
  instruction              = var.agent_instruction

  agent_alias_name         = var.agent_alias_name
  agent_role_name          = var.agent_role_name
  agent_role_policies      = var.agent_role_policies

  kb_s3_bucket_arn         = var.kb_s3_bucket_arn
  kb_embedding_model_arn   = var.kb_embedding_model_arn

  guardrails_name          = var.guardrails_name
  guardrails_description   = var.guardrails_description
  
  action_group_function_parameters = var.action_group_function_parameters
  
  tags = module.this.tags
}

resource "aws_opensearchserverless_collection" "kb_collection" {
  name        = var.opensearch_collection_name
  description = var.opensearch_collection_description
  type        = "VECTORSEARCH"
  tags        = module.this.tags
}

resource "aws_bedrock_knowledge_base" "agent_kb" {
  name        = var.bedrock_kb_name
  description = var.kb_description
  role_arn    = var.kb_role_arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = var.kb_embedding_model_arn
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.kb_collection.arn
      vector_index_name = var.opensearch_index_name
      field_mapping {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
    }
  }

  depends_on = [aws_opensearchserverless_collection.kb_collection]
  tags       = module.this.tags
}