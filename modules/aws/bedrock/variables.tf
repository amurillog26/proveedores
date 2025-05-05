variable "name" {
  type        = string
  description = "Name tag value usually describes the component or solution name"
}

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

variable "s3_inclusion_prefixes" {
  type        = list(string)
  description = "(Optional) List of S3 prefixes that define the object containing the data sources"
  default     = []
}

variable "oass_collection_name" {
  type        = string
  description = "Name of the OpenSearch Serverless collection"
}

variable "oass_collection_desc" {
  type        = string
  description = "Description for the OpenSearch Serverless collection"
  default     = "Collection created for Amazon Bedrock Knowledge Base"
}

variable "oass_collection_type" {
  type        = string
  description = "Type of the OpenSearch Serverless collection"
  default     = "VECTORSEARCH"
}

variable "oass_network_security_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless network security policy"
}

variable "oass_encryption_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless encryption policy"
}

variable "oass_data_access_policy_name" {
  type        = string
  description = "Name of the OpenSearch Serverless data access policy"
}

variable "oass_data_access_policy_desc" {
  type        = string
  description = "Description for the OpenSearch Serverless data access policy"
  default     = "Data access policy for the specified IAM role"
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index"
}

variable "vector_field" {
  type        = string
  description = "Name of the vector field in the index"
}

variable "metadata_field" {
  type        = string
  description = "Name of the metadata field in the index"
  default     = "AMAZON_BEDROCK_METADATA"
}

variable "text_field" {
  type        = string
  description = "Name of the text field in the index"
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "kb_embedding_model_arn" {
  type        = string
  description = "The ARN of the embedding model to be used by the Knowledge Base"
}

variable "kb_model_id" {
  type        = string
  description = "The ID of the foundational model used by the knowledge base"
}

variable "kb_configuration_type" {
  type        = string
  description = "The type of the Knowledge Base"
  default     = "VECTOR"
}

variable "t_tf_role" {
  type        = string
  description = "Role name for OpenSearch provider"
}

variable "t_account_id" {
  type        = string
  description = "AWS Account ID for OpenSearch provider"
}

variable "t_external_id" {
  type        = string
  description = "External ID for OpenSearch provider"
}

variable "oass_owner_policy_access" {
  type        = string
  description = "Additional role to assume for accessing OpenSearch collection indexes"
  default     = "AWSReservedSSO_ADC-CloudEngineer_55d664f2862c3727"
}
