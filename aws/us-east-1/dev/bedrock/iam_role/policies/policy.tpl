{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaInvoke",
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${lambda_function_arn}"
      ]
    },
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${s3_bucket_arn}",
        "${s3_bucket_arn}/*"
      ]
    },
    {
      "Sid": "OpenSearchAccessCollectionAndIndex",
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll",
        "aoss:CreateIndex",
        "aoss:DeleteIndex",
        "aoss:DescribeIndex",
        "aoss:ReadDocument",
        "aoss:WriteDocument",
        "aoss:UpdateIndex",
        "aoss:DescribeCollectionItems",
        "aoss:CreateCollectionItems",
        "aoss:UpdateCollectionItems"
      ],
      "Resource": [
        "${opensearch_collection}",
        "${opensearch_index}"
      ]
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
