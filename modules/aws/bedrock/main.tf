# Refer to: https://blog.avangards.io/how-to-manage-an-amazon-bedrock-knowledge-base-using-terraform

# Create the OpenSearch Serverless collection
resource "aws_opensearchserverless_collection" "this" {
  name        = var.oass_collection_name
  description = var.oass_collection_desc
  type        = var.oass_collection_type
  tags        = module.this.tags
  depends_on = [
    aws_opensearchserverless_security_policy.network_policy,
    aws_opensearchserverless_security_policy.encryption_policy
  ]
}

resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = var.oass_network_security_policy_name
  description = var.oass_collection_desc
  type        = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection",
          Resource     = ["collection/${var.oass_collection_name}"]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = var.oass_encryption_policy_name
  description = "Encryption policy using AWS owned key"
  type        = "encryption"

  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection",
        Resource     = ["collection/${var.oass_collection_name}"]
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = var.oass_data_access_policy_name
  description = var.oass_data_access_policy_desc
  type        = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${var.oass_collection_name}/*"
          ],
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:UpdateIndex",
            "aoss:WriteDocument"
          ]
        },
        {
          ResourceType = "collection",
          Resource     = ["collection/${var.oass_collection_name}"]
          Permission = [
            "aoss:DescribeCollectionItems",
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ],
      Principal = [
        var.kb_role_arn,
        join("", ["arn:aws:iam::", var.t_account_id, ":role/", var.t_tf_role]),
        join("", ["arn:aws:sts::", var.t_account_id, ":assumed-role/", var.oass_owner_policy_access, "/*"])
      ]
    }
  ])
}

# We need specific permissions in the collection_id;
# collection_name seems to not been working
resource "aws_iam_role_policy" "bedrock_kb_hrchat_oss" {
  name = "AmazonBedrockOSSPolicyForKnowledgeBase_chatbot"
  # role = aws_iam_role.bedrock_kb_forex_kb.name
  role = var.kb_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "aoss:APIAccessAll"
        Effect   = "Allow"
        Resource = aws_opensearchserverless_collection.this.arn
      }
    ]
  })
}

# Wait for the role policy to be attache/propagate to the role before creating the collection
resource "time_sleep" "aws_iam_role_policy_bedrock_kb_hrchat_oss" {
  create_duration = "20s"
  depends_on      = [aws_iam_role_policy.bedrock_kb_hrchat_oss]
}

# Note that the healthcheck argument is set to false because the
#client health check does not really work with OpenSearch Serverless.
provider "opensearch" {
  alias                       = "cc"
  url                         = aws_opensearchserverless_collection.this.collection_endpoint
  aws_assume_role_arn         = join("", ["arn:aws:iam::", var.t_account_id, ":role/", var.t_tf_role])
  aws_assume_role_external_id = var.t_external_id
  healthcheck                 = false
}

resource "opensearch_index" "hrchat_kb" {
  provider                       = opensearch.cc
  name                           = var.vector_index_name
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "${var.oass_collection_name}-vector": {
          "type": "knn_vector",
          "dimension": 1024,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                  = true
  depends_on = [
    aws_opensearchserverless_collection.this,
    aws_opensearchserverless_access_policy.data_access_policy
  ]
}

resource "aws_bedrockagent_knowledge_base" "kb_bedrock" {
  name        = var.name
  description = var.kb_description
  role_arn    = var.kb_role_arn

  knowledge_base_configuration {
    type = var.kb_configuration_type
    vector_knowledge_base_configuration {
      embedding_model_arn = var.kb_embedding_model_arn
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = var.vector_index_name
      field_mapping {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
    }
  }

  tags = module.this.tags
  depends_on = [
    aws_iam_role_policy.bedrock_kb_hrchat_oss,
    time_sleep.aws_iam_role_policy_bedrock_kb_hrchat_oss,
    opensearch_index.hrchat_kb
  ]
}

resource "aws_bedrockagent_data_source" "forex_kb" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.kb_bedrock.id
  name              = "${var.name}-datasource"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.s3_bucket_arn
    }
  }
}

# Nuevos recursos para Bedrock Agent
resource "aws_bedrockagent_agent" "this" {
  count                       = var.create_agent ? 1 : 0
  agent_name                  = var.agent_name
  agent_resource_role_arn     = var.agent_resource_role_arn
  idle_session_ttl_in_seconds = var.idle_session_ttl_in_seconds
  foundation_model            = var.agent_foundation_model
  description                 = var.agent_description
  instruction                 = var.agent_instruction
  agent_collaboration         = var.agent_collaboration
  prepare_agent               = var.agent_prepare_agent

  dynamic "guardrail_configuration" {
    for_each = var.agent_guardrail_identifier != null && var.agent_guardrail_version != null ? [1] : []
    content {
      guardrail_identifier = var.agent_guardrail_identifier
      guardrail_version    = var.agent_guardrail_version
    }
  }

  dynamic "memory_configuration" {
    for_each = var.agent_memory_enabled ? [1] : []
    content {
      enabled_memory_types = var.agent_memory_enabled_types
      storage_days         = var.agent_memory_storage_days
    }
  }

  tags = module.this.tags
}

# Usar el nombre correcto del recurso según la documentación oficial
resource "aws_bedrockagent_agent_knowledge_base_association" "this" {
  count                = var.create_agent ? 1 : 0
  agent_id             = aws_bedrockagent_agent.this[0].id
  knowledge_base_id    = aws_bedrockagent_knowledge_base.kb_bedrock.id
  description          = var.kb_association_description
  knowledge_base_state = "ENABLED"
}

resource "aws_bedrockagent_agent_action_group" "p2p_functions" {
  count             = var.create_agent ? 1 : 0
  agent_id          = aws_bedrockagent_agent.this[0].id
  agent_version     = "DRAFT"
  action_group_name = "P2PFunctions"
  description       = "Finance P2P (Procure to Pay) functions for provider inquiries"

  # Definimos el esquema de funciones usando la sintaxis de bloques correcta
  function_schema {
    member_functions {
      functions {
        name        = "account_statement"
        description = "Obtener estado de cuenta de proveedor"
        parameters {
          map_block_key = "provider_id"
          type          = "string"
          description   = "ID del proveedor o código de proveedor"
          required      = true
        }
      }
      
      functions {
        name        = "invoice_statement"
        description = "Obtener estado de factura"
        parameters {
          map_block_key = "provider_id"
          type          = "string"
          description   = "ID del proveedor o código de proveedor"
          required      = true
        }
        parameters {
          map_block_key = "invoice_number"
          type          = "string"
          description   = "Número de factura"
          required      = true
        }
      }
      
      functions {
        name        = "special_payment_status"
        description = "Consultar estado de pago especial"
        parameters {
          map_block_key = "special_payment_number"
          type          = "string"
          description   = "Número del pago especial"
          required      = true
        }
      }
      
      functions {
        name        = "payment_details"
        description = "Obtener detalles de pago"
        parameters {
          map_block_key = "transaction_number"
          type          = "string"
          description   = "Número de transacción"
          required      = true
        }
        parameters {
          map_block_key = "payment_date"
          type          = "string"
          description   = "Fecha de pago"
          required      = true
        }
      }
      
      functions {
        name        = "travel_expenditures"
        description = "Confirmación de pago de gastos de viaje"
        parameters {
          map_block_key = "employee_id"
          type          = "string"
          description   = "ID del empleado"
          required      = true
        }
        parameters {
          map_block_key = "invoice_number"
          type          = "string"
          description   = "Número de factura"
          required      = true
        }
      }
      
      functions {
        name        = "purchase_delivery_date"
        description = "Fecha de entrega de orden"
        parameters {
          map_block_key = "purchase_order"
          type          = "string"
          description   = "Número de orden de compra"
          required      = true
        }
        parameters {
          map_block_key = "purchase_position"
          type          = "string"
          description   = "Posición de compra"
          required      = true
        }
      }
    }
  }

  # Mantenemos el ejecutor Lambda
  action_group_executor {
    lambda = var.agent_action_group_lambda_arn
  }
}
