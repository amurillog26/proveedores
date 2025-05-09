output "agent_knowledge_base_id" {
  description = "The ID of the AWS Bedrock Agent Knowledge Base association"
  value       = aws_bedrockagent_knowledge_base.kb_bedrock.id
}

# Nuevos outputs para Bedrock Agent
output "agent_id" {
  description = "Unique identifier of the agent"
  value       = var.create_agent ? aws_bedrockagent_agent.this[0].agent_id : null
}

output "agent_arn" {
  description = "ARN of the agent"
  value       = var.create_agent ? aws_bedrockagent_agent.this[0].agent_arn : null
}

output "agent_version" {
  description = "Version of the agent"
  value       = var.create_agent ? aws_bedrockagent_agent.this[0].agent_version : null
}

output "kb_association_id" {
  description = "ID of the knowledge base association"
  value       = var.create_agent ? aws_bedrockagent_agent_knowledge_base_association.this[0].id : null
}

output "agent_alias_id" {
  description = "ID of the agent alias"
  value       = var.create_agent && var.create_agent_version && var.create_agent_alias ? aws_bedrockagent_agent_alias.production[0].agent_alias_id : null
}

output "agent_action_group_id" {
  description = "ID of the agent action group"
  value       = var.create_agent ? aws_bedrockagent_agent_action_group.p2p_functions[0].id : null
}
