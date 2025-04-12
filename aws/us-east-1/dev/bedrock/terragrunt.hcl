include "root" {
  path   = find_in_parent_folders("dev/terragrunt.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/aws"
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
    bucket_arn = "arn:aws:s3:::mock-kb-bucket"
  }
}

dependency "iam_roles" {
  config_path = "./iam_role"

  mock_outputs = {
    kb_role_arn    = "arn:aws:iam::123456789012:role/mock-kb-role"
    agent_role_arn = "arn:aws:iam::123456789012:role/mock-agent-role"
  }
}

inputs = {
  foundation_model       = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  agent_instruction      = "You are a helpful assistant for querying financial documents."
  agent_alias_name       = "p2p-bedrock-agent"
  agent_role_name        = "bedrock-agent-role"
  agent_role_policies    = ["arn:aws:iam::aws:policy/AmazonBedrockFullAccess", "arn:aws:iam::aws:policy/AWSLambdaRole"]
  kb_s3_bucket_arn       = dependency.kb_bucket.outputs.arn
  kb_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  guardrails_name        = "p2p-bedrock-guardrails"
  guardrails_description = "Guardrails for P2P Bedrock Agent"

  opensearch_collection_name        = "p2p-bedrock-collection"
  opensearch_collection_description = "OpenSearch collection for P2P Bedrock Knowledge Base"

  bedrock_kb_name = "p2p-kb"
  kb_description  = "Knowledge base for P2P vendor financial inquiries"
  kb_role_arn     = dependency.iam_roles.outputs.kb_role_arn

  opensearch_index_name = "p2p-kb-index"
  text_field            = "AMAZON_BEDROCK_TEXT_CHUNK"
  metadata_field        = "AMAZON_BEDROCK_METADATA"
  vector_field          = "p2p-bedrock-collection-vector"
  
  action_group_function_parameters = [
    {
      function_name = "account_statement"
      parameters = [
        {
          name        = "provider_code"
          description = "The provider’s account code"
          type        = "string"
          required    = true
        }
      ]
    },
    {
      function_name = "invoice_statement"
      parameters = [
        {
          name        = "provider_code"
          description = "The provider’s account code"
          type        = "string"
          required    = true
        },
        {
          name        = "invoice_number"
          description = "Reference number of the invoice"
          type        = "string"
          required    = true
        },
        {
          name        = "country"
          description = "Country of the provider"
          type        = "string"
          required    = false
        }
      ]
    },
    {
      function_name = "special_payment_status"
      parameters = [
        {
          name        = "request_number"
          description = "Special payment request number"
          type        = "string"
          required    = true
        }
      ]
    },
    {
      function_name = "payment_details"
      parameters = [
        {
          name        = "provider_code"
          description = "The provider’s account code"
          type        = "string"
          required    = true
        },
        {
          name        = "compensation_date"
          description = "Payment date in dd/mm/yyyy format"
          type        = "string"
          required    = true
        }
      ]
    },
    {
      function_name = "travel_expenditures"
      parameters = [
        {
          name        = "provider_code"
          description = "The provider’s account code"
          type        = "string"
          required    = true
        },
        {
          name        = "invoice_number"
          description = "Reference number of the travel expense invoice"
          type        = "string"
          required    = true
        }
      ]
    },
    {
      function_name = "purchase_delivery_date"
      parameters = [
        {
          name        = "purchase_order"
          description = "Purchase order number"
          type        = "string"
          required    = true
        },
        {
          name        = "purchase_position"
          description = "Position in the purchase order"
          type        = "string"
          required    = true
        }
      ]
    }
  ]
}
