resource "aws_bedrockagent_agent_action_group" "p2p_functions" {
  count             = var.create_agent ? 1 : 0
  agent_id          = aws_bedrockagent_agent.this[0].id
  agent_version     = "DRAFT"
  action_group_name = "P2PFunctions"
  description       = "Finance P2P (Procure to Pay) functions for provider inquiries"

  # Define the Lambda function ARN for your action group
  action_group_executor {
    lambda = var.agent_action_group_lambda_arn
  }

  # Schema for the action group
  parent_action_group_signature = jsonencode({
    "actionGroupInvocationSchema" : {
      "name" : "P2P_Invoice_Payment_Functions",
      "description" : "Functions to handle provider inquiries related to invoices, payments, and orders",
      "action" : {
        "type" : "LAMBDA",
        "parameters" : [
          {
            "name" : "function_name",
            "description" : "The function to execute",
            "type" : "string",
            "required" : true,
            "enum" : ["account_statement", "invoice_statement", "special_payment_status", "payment_details", "travel_expenditures", "purchase_delivery_date"]
          },
          {
            "name" : "provider_id",
            "description" : "Provider ID or código de proveedor",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "invoice_number",
            "description" : "Invoice number",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "special_payment_number",
            "description" : "Special payment number or número del pago especial",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "transaction_number",
            "description" : "Transaction number",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "payment_date",
            "description" : "Payment date",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "employee_id",
            "description" : "Employee ID",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "purchase_order",
            "description" : "Purchase order number",
            "type" : "string",
            "required" : false
          },
          {
            "name" : "purchase_position",
            "description" : "Purchase position",
            "type" : "string",
            "required" : false
          }
        ]
      },
      "functionGroups" : [
        {
          "name" : "account_statement",
          "description" : "Get account statement for a provider",
          "parameters" : ["provider_id"]
        },
        {
          "name" : "invoice_statement",
          "description" : "Get status of an invoice",
          "parameters" : ["provider_id", "invoice_number"]
        },
        {
          "name" : "special_payment_status",
          "description" : "Get status of a special payment",
          "parameters" : ["special_payment_number"]
        },
        {
          "name" : "payment_details",
          "description" : "Get payment details",
          "parameters" : ["transaction_number", "payment_date"]
        },
        {
          "name" : "travel_expenditures",
          "description" : "Confirm payment of travel expenses",
          "parameters" : ["employee_id", "invoice_number"]
        },
        {
          "name" : "purchase_delivery_date",
          "description" : "Get order delivery date",
          "parameters" : ["purchase_order", "purchase_position"]
        }
      ]
    }
  })
}


resource "aws_bedrockagent_agent_version" "this" {
  count = var.create_agent && var.create_agent_version ? 1 : 0

  agent_id    = aws_bedrockagent_agent.this[0].id
  agent_name  = aws_bedrockagent_agent.this[0].agent_name
  description = "Version with P2P functions for ${var.agent_name}"

  # Use the prompt provided by the user
  agent_version_instruction = var.agent_version_instruction

  # Include the action groups in the version
  agent_action_groups = [
    aws_bedrockagent_agent_action_group.p2p_functions[0].id
  ]

  # Include knowledge bases in this version
  agent_knowledge_base_associations = [
    aws_bedrockagent_agent_knowledge_base_association.this[0].id
  ]

  # Foundation model to use
  foundation_model = var.agent_foundation_model

  # Memory configuration
  dynamic "memory_configuration" {
    for_each = var.agent_memory_enabled ? [1] : []
    content {
      enabled_memory_types = var.agent_memory_enabled_types
      storage_days         = var.agent_memory_storage_days
    }
  }
}

resource "aws_bedrockagent_agent_alias" "production" {
  count = var.create_agent && var.create_agent_version && var.create_agent_alias ? 1 : 0

  agent_id         = aws_bedrockagent_agent.this[0].id
  agent_alias_name = var.agent_alias_name
  description      = "Production alias for ${var.agent_name}"
}
