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
        "${vars.s3_bucket_arn}",
        "${vars.s3_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll",
        "aoss:CreateCollection",
        "aoss:CreateSecurityPolicy",
        "aoss:CreateAccessPolicy",
        "aoss:BatchGetCollection",
        "aoss:ListCollections",
        "aoss:DescribeCollection",
        "aoss:DescribeIndex",
        "aoss:CreateIndex",
        "aoss:DeleteIndex",
        "aoss:UpdateIndex",
        "aoss:DescribeCollectionItems",
        "aoss:SearchCollectionItems",
        "aoss:CreateCollectionItems",
        "aoss:DeleteCollectionItems",
        "aoss:UpdateCollectionItems"
      ],
      "Resource": [
        "${vars.opensearch_collection}",
        "${vars.opensearch_index}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": "*"
    }
  ]
}
