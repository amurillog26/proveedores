{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${vars.input_bucket_arn}",
        "${vars.input_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${vars.kb_bucket_arn}",
        "${vars.kb_bucket_arn}/*",
        "${vars.query_bucket_arn}",
        "${vars.query_bucket_arn}/*",
        "${vars.athena_results_arn}",
        "${vars.athena_results_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ],
      "Resource": "${vars.kms_key_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:GetDatabases",
        "glue:GetTable",
        "glue:GetTables",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:CreateTable",
        "glue:UpdateTable",
        "glue:DeleteTable",
        "lakeformation:GetDataAccess",
        "lakeformation:ListPermissions",
        "lakeformation:ListResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "athena:StartQueryExecution",
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:StopQueryExecution",
        "athena:ListDataCatalogs",
        "athena:ListDatabases",
        "athena:ListTableMetadata",
        "athena:ListQueryExecutions"
      ],
      "Resource": [
        "arn:aws:athena:${vars.region}:${vars.account_id}:workgroup/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeAgent",
        "bedrock:ListAgents",
        "bedrock:ListAgentAliases",
        "bedrock:GetAgent"
      ],
      "Resource": [
        "arn:aws:bedrock:${vars.region}:${vars.account_id}:agent/*",
        "arn:aws:bedrock:${vars.region}::foundation-model/*"
      ]
    }
  ]
}
