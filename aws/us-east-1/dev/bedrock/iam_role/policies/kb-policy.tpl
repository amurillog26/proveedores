{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockInvokeModelStatement",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": [
        "arn:aws:bedrock:${region}::foundation-model/amazon.titan-embed-text-v2:0",
        "arn:aws:bedrock:${region}::foundation-model/Anthropic.claude-sonnet-3",
        "arn:aws:bedrock:${region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0",
        "arn:aws:bedrock:${region}::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"
      ]
    },
    {
      "Sid": "S3ListBucketStatement",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${s3_arn}",
        "${s3_arn}/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceAccount": [
            "${account_id}"
          ]
        }
      }
    },
    {
      "Sid": "S3GetObjectStatement",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${s3_arn}",
        "${s3_arn}/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceAccount": [
            "${account_id}"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "ForAnyValue:StringLike": {
          "kms:ResourceAliases": ${kms_alias}
        }
      }
    },
    {
      "Sid": "OpenSearchServerlessAPIAccessAllStatement",
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll"
      ],
      "Resource": [
        "arn:aws:aoss:${region}:${account_id}:collection/*"
      ],
      "Condition": {
        "StringLike": {
          "aws:RequestTag/project": "${project}",
          "aws:ResourceTag/project": "${project}"
        }
      }
    }
  ]
}
