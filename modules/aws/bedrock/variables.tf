variable "kb_description" {
  type        = string
  description = "The description of the Knowledge Base"
}
variable "kb_role_arn" {
  type        = string
  description = "The ARN of the role to assume when accessing the Knowledge Base"
}

variable "kb_role_name" {
  type        = string
  description = "The name of the role to assume when accessing the Knowledge Base"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to store the Knowledge Base"
}

variable "oass_collection_name" {
  type        = string
  description = "Name of the OpenSearch Serverless collection"
}

variable "oass_collection_desc" {
  type        = string
  description = "Default collection created for Amazon Bedrock KB HR Chatbot"
  default     = "Default collection created for Amazon Bedrock KB HR Chatbot"
}

variable "oass_collection_type" {
  type        = string
  description = "Type of the OpenSearch Serverless collection"
  default     = "VECTORSEARCH"
}

variable "oass_network_security_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless security policy"
}

variable "oass_network_security_policy_desc" {
  type        = string
  description = "Network access policy for OpenSearch endpoints and dashboards"
  default     = "access policy for OpenSearch endpoints and dashboards"
}

variable "oass_encryption_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless security policy"
}

variable "oass_encryption_policy_desc" {
  type        = string
  description = "Encryption policy using AWS owned key"
  default     = "Encryption policy using AWS owned key"
}

variable "oass_data_access_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless data access policy"
}

variable "oass_data_access_policy_desc" {
  type        = string
  description = "Data access policy for the specified IAM role"
  default     = "Data access policy for the specified IAM role"
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index"
}

variable "vector_field" {
  type = string
}

variable "metadata_field" {
  type    = string
  default = "AMAZON_BEDROCK_METADATA"
}

variable "text_field" {
  type        = string
  description = "Amazon Bedrock text field storage name"
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "kb_embedding_model_arn" {
  type        = string
  description = "The ARN of the embedding model to be used by the Knowledge Base"
}

variable "kb_model_id" {
  description = "The ID of the foundational model used by the knowledge base."
  type        = string
  # default     = "amazon.titan-embed-text-v1"
}

variable "kb_configuration_type" {
  type        = string
  description = "The type of the Knowledge Base"
  default     = "VECTOR"
}

variable "t_tf_role" {
  type        = string
  description = "Role ARN for Opensearch provider"
}

variable "t_account_id" {
  type        = string
  description = "AWS Account ID for Opensearch provider"
}

variable "t_external_id" {
  type        = string
  description = "External ID for Opensearch provider"
}

variable "oass_owner_policy_access" {
  type        = string
  description = "Additional role to assume for accessing oass collection indexes"
  default     = "AWSReservedSSO_ADC-CloudEngineer_55d664f2862c3727"
}

# Variables for Bedrock Agent
variable "create_agent" {
  type        = bool
  description = "Whether to create a Bedrock agent"
  default     = false
}

variable "agent_name" {
  type        = string
  description = "Name of the Bedrock agent"
  default     = ""
}

variable "agent_resource_role_arn" {
  type        = string
  description = "ARN of the IAM role with permissions to invoke API operations on the agent"
  default     = ""
}

variable "agent_foundation_model" {
  type        = string
  description = "Foundation model used for orchestration by the agent"
  default     = "anthropic.claude-v2"
}

variable "agent_description" {
  type        = string
  description = "Description of the Bedrock agent"
  default     = ""
}

variable "idle_session_ttl_in_seconds" {
  type        = number
  description = "Number of seconds for which Amazon Bedrock keeps information about a user's conversation with the agent"
  default     = 900
}

variable "agent_instruction" {
  type        = string
  description = "Instructions that tell the agent what it should do and how it should interact with users"
  default     = ""
}

variable "agent_collaboration" {
  type        = string
  description = "Agents collaboration role"
  default     = "DISABLED"
}

variable "agent_prepare_agent" {
  type        = bool
  description = "Whether to prepare the agent after creation or modification"
  default     = true
}

variable "agent_guardrail_identifier" {
  type        = string
  description = "Unique identifier of the guardrail"
  default     = null
}

variable "agent_guardrail_version" {
  type        = string
  description = "Version of the guardrail"
  default     = null
}

variable "agent_memory_enabled" {
  type        = bool
  description = "Whether to enable memory for the agent"
  default     = false
}

variable "agent_memory_enabled_types" {
  type        = list(string)
  description = "The type of memory being stored by the agent"
  default     = ["SESSION_SUMMARY"]
}

variable "agent_memory_storage_days" {
  type        = number
  description = "The number of days the agent is configured to retain the conversational context"
  default     = 30
}

variable "kb_association_description" {
  type        = string
  description = "Description of the knowledge base association"
  default     = "Bedrock knowledge base associated with agent"
}
