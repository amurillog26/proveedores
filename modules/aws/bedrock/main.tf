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

# Create or use the IAM role
resource "aws_iam_role" "bedrock_kb_role" {
  count              = var.create_iam_role ? 1 : 0
  name               = "${var.name}-role"
  assume_role_policy = file(var.assume_role_file_path)
}

# Modificar la política de plantilla en kb-policy.tpl para incluir permisos de API Access
resource "aws_iam_role_policy" "bedrock_kb_policy" {
  count  = var.create_iam_role ? 1 : 0
  name   = "${var.name}-policy"
  role   = aws_iam_role.bedrock_kb_role[0].name
  policy = templatefile(var.policy_file_path, var.policy_vars)
}

resource "time_sleep" "wait_for_new_role_policy" {
  count           = var.create_iam_role ? 1 : 0
  create_duration = "20s"
  depends_on      = [aws_iam_role_policy.bedrock_kb_policy]
}

provider "opensearch" {
  alias                       = "cc"
  url                         = aws_opensearchserverless_collection.this.collection_endpoint
  aws_assume_role_arn         = join("", ["arn:aws:iam::", var.t_account_id, ":role/", var.t_tf_role])
  aws_assume_role_external_id = var.t_external_id
  healthcheck                 = false
}

resource "opensearch_index" "kb_vector_index" {
  provider                       = opensearch.cc
  name                           = var.vector_index_name
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "${var.vector_field}": {
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
        "${var.metadata_field}": {
          "type": "text",
          "index": "false"
        },
        "${var.text_field}": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                  = true
  depends_on = [
    aws_opensearchserverless_collection.this,
    time_sleep.wait_for_new_role_policy
  ]
}

resource "aws_bedrockagent_knowledge_base" "kb_bedrock" {
  name        = var.name
  description = var.kb_description
  role_arn    = var.create_iam_role ? aws_iam_role.bedrock_kb_role[0].arn : var.kb_role_arn

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
    time_sleep.wait_for_new_role_policy,
    opensearch_index.kb_vector_index
  ]
}

resource "aws_bedrockagent_data_source" "kb_s3_datasource" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.kb_bedrock.id
  name              = "${var.name}-datasource"

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 800
        overlap_percentage = 20
      }
    }
  }
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn         = var.s3_bucket_arn
      inclusion_prefixes = var.s3_inclusion_prefixes
    }
  }
}
