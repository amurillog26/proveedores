include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_terragrunt_dir()}/../../../..//modules/aws/bedrock/"
}

dependency "s3" {
  config_path = "../s3/kb_bucket"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show", "destroy"]
  mock_outputs = {
    arn    = "arn:aws:s3:::fake-bucket"
    bucket = "fake-bucket"
  }
}

dependency "kb_exec_role" {
  config_path = "../iam_role"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "fmt", "show"]
  mock_outputs = {
    role_arn  = "arn:aws:iam::123456789012:role/FakeRole"
    role_name = "fake_role_name"
  }
}

locals {
  name       = "${include.parent.locals.global.project}-${include.parent.locals.environment}"
  region     = include.parent.locals.global.aws_region
  account_id = include.parent.locals.account_id
}

inputs = {
  name           = local.name
  kb_description = "Bedrock P2P"
  region         = local.region
  id_account     = local.account_id

  #AWS OpenSearch Serverless related variables
  oass_collection_name              = "${include.parent.locals.global.project}-${include.parent.locals.environment}"
  oass_network_security_policy_name = "p2p-ia-pub-net-policy-${include.parent.locals.environment}"
  oass_encryption_policy_name       = "p2p-ia-encrypt-policy-${include.parent.locals.environment}"
  oass_data_access_policy_name      = "p2p-ia-data-access-policy-${include.parent.locals.environment}"

  kb_role_arn   = dependency.kb_exec_role.outputs.role_arn
  kb_role_name  = dependency.kb_exec_role.outputs.role_name
  s3_bucket_arn = dependency.s3.outputs.arn

  vector_index_name      = "${include.parent.locals.global.project}-${include.parent.locals.environment}-default-index"
  vector_field           = "${include.parent.locals.global.project}-${include.parent.locals.environment}-vector"
  kb_embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
  kb_model_id            = "amazon.titan-embed-text-v2:0"
  kb_configuration_type  = "VECTOR"

  t_account_id  = include.parent.locals.account_id
  t_external_id = include.parent.locals.global.external_id
  t_tf_role     = include.parent.locals.global.trust_role
  
  create_agent            = true
  agent_name              = "${local.name}-agent"
  agent_resource_role_arn = dependency.kb_exec_role.outputs.role_arn
  agent_foundation_model  = "anthropic.claude-3-5-sonnet-20240620-v1:0"  # Claude 3.5 Sonnet
  agent_description       = "Bedrock Agent for P2P procurement information using Claude 3.5 Sonnet"
  # Added action group configuration
  agent_action_group_lambda_arn = "arn:aws:lambda:us-east-1:745315529340:function:p2pMax"
  
  # Version and alias configuration
  create_agent_version = true
  create_agent_alias   = true
  agent_alias_name     = "production"
  
  # The prompt provided by the user
  agent_version_instruction = <<EOF
You are Max P2P, a useful virtual assistant that runs the next tasks:
- Get Account Statement: to run this task you will receive the provider id or "código de proveedor" in Spanish from end user and then get the answer using the function account_statement within the lambda p2pMax
 
- Get Invoice Status: to run this task you will receive the provider id or "código de proveedor" in Spanish and the invoice number from end user and then use the function invoice_statement within the lambda p2pMax. you sometimes will receive a data and you should print it as a table.
 
- Special Payment Status: to run this task you will receive the special payment number or "número del pago especial" in Spanish from end user and then get answers using the function special_payment_status within the lambda p2pMax
 
- Payment Details: to run this task you will receive the transaction number and payment date from end user and then get answers using the function payment_details within the lambda p2pMax
 
- Confirmation of payment of travel expenses: to run this task you will receive the employee id and invoice number from end user and then get answers using the function travel_expenditures within the lambda p2pMax
 
- Order delivery date: to run this task you will receive the purchase order and purchase position from end user and then get answers using the function purchase_delivery_date within the lambda p2pMax
 
Additionally, you are able to answer questions about SAP material creation using the knowledge base p2p_kb
 
You can receive prompts in Spanish and it is expected you return answers in Spanish
Indicate when you are returning monetary results based in the table fields definitions.
Round results up to two decimals.
 
Return all the  <function_results> results you get and present them as table of results  when you receive the entrance named data within the json file you receive.
EOF

  agent_memory_enabled         = true
  agent_memory_enabled_types   = ["SESSION_SUMMARY"]
  agent_memory_storage_days    = 14
  
  kb_association_description = "Knowledge base for procurement information"
}
