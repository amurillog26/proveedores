output "kb_id" {
  description = "The Amazon Bedrock Knowledge Base ID"
  value       = aws_bedrockagent_knowledge_base.kb_bedrock.id
}

output "kb_arn" {
  description = "The Amazon Bedrock Knowledge Base ARN"
  value       = aws_bedrockagent_knowledge_base.kb_bedrock.arn
}

output "opensearch_collection_id" {
  description = "The OpenSearch Serverless collection ID"
  value       = aws_opensearchserverless_collection.this.id
}

output "opensearch_collection_arn" {
  description = "The OpenSearch Serverless collection ARN"
  value       = aws_opensearchserverless_collection.this.arn
}

output "opensearch_collection_endpoint" {
  description = "The OpenSearch Serverless collection endpoint"
  value       = aws_opensearchserverless_collection.this.collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "The OpenSearch Serverless dashboard endpoint"
  value       = aws_opensearchserverless_collection.this.dashboard_endpoint
}

output "vector_index_name" {
  description = "The vector index name"
  value       = var.vector_index_name
}

output "data_source_id" {
  description = "The data source ID"
  value       = aws_bedrockagent_data_source.kb_s3_datasource.id
}
