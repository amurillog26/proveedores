output "agent_knowledge_base_id" {
  description = "The ID of the AWS Bedrock Agent Knowledge Base association"
  value       = aws_bedrockagent_knowledge_base.kb_bedrock.id
}