output "bedrock_agent_id" {
  description = "The ID of the created Bedrock agent."
  value       = module.bedrock.agent_id
}

output "bedrock_alias_id" {
  description = "The ID of the Bedrock agent alias."
  value       = module.bedrock.agent_alias_id
}

output "knowledge_base_id" {
  description = "The ID of the created knowledge base."
  value       = module.bedrock.knowledge_base_id
}

output "guardrails_id" {
  description = "The ID of the created Bedrock guardrails."
  value       = module.bedrock.guardrails_id
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection used by the KB"
  value       = aws_opensearchserverless_collection.kb_collection.arn
}