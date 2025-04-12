variable "foundation_model" {
  description = "ID of the foundation model to use (e.g., 'anthropic.claude-3-5-sonnet-20240620-v1:0')"
  type        = string
}

variable "agent_instruction" {
  description = "Initial instruction prompt for the Bedrock agent."
  type        = string
}

variable "agent_alias_name" {
  description = "Alias name for the Bedrock agent."
  type        = string
}

variable "agent_role_name" {
  description = "Name of the IAM role to assign to the Bedrock agent."
  type        = string
}

variable "agent_role_policies" {
  description = "List of policy ARNs to attach to the Bedrock agent role."
  type        = list(string)
}

variable "kb_s3_bucket_arn" {
  description = "ARN of the S3 bucket that contains knowledge base documents."
  type        = string
}

variable "kb_embedding_model_arn" {
  description = "ARN of the embedding model to use in the knowledge base (e.g., Titan embedding)."
  type        = string
}

variable "guardrails_name" {
  description = "Name for the Bedrock guardrails."
  type        = string
}

variable "guardrails_description" {
  description = "Description for the Bedrock guardrails."
  type        = string
}

variable "opensearch_collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  type        = string
}

variable "opensearch_collection_description" {
  description = "Description of the OpenSearch Serverless collection"
  type        = string
}

variable "bedrock_kb_name" {
  description = "Name of the knowledge base"
  type        = string
}

variable "kb_description" {
  description = "Description of the knowledge base"
  type        = string
}

variable "kb_role_arn" {
  description = "IAM role ARN to be used by the knowledge base"
  type        = string
}

variable "opensearch_index_name" {
  description = "OpenSearch vector index name"
  type        = string
}

variable "text_field" {
  description = "Field for unstructured text in OpenSearch"
  type        = string
}

variable "metadata_field" {
  description = "Field for metadata in OpenSearch"
  type        = string
}

variable "vector_field" {
  description = "Field for vector embeddings in OpenSearch"
  type        = string
}

variable "action_group_function_parameters" {
  description = "Parameters definitions for each function used by the Bedrock agent via Action Group"
  type = list(object({
    function_name = string
    parameters = list(object({
      name        = string
      description = string
      type        = string
      required    = bool
    }))
  }))
  default = []
}