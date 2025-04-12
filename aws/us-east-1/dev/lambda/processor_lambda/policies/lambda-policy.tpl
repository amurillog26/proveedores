{
  "Statement": [
      {
          "Action": [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:GetObjectTagging",
              "s3:PutObjectTagging",
              "s3:ReplicateObject",
              "s3:ListBucket"
          ],
          "Effect": "Allow",
          "Resource": [
              "${s3_source_arn}",
              "${s3_source_arn}/*"
          ]
      },
      {
          "Action": [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey",
              "kms:ListGrants"
          ],
          "Condition": {
              "ForAnyValue:StringLike": {
                  "kms:ResourceAliases": [
                      "alias/io-la-s3-encrypt",
                      "alias/io-la-secretsmanager-encrypt"
                  ]
              }
          },
          "Effect": "Allow",
          "Resource": [
              "arn:aws:kms:${aws_region}:${account_id}:key/*"
          ]
      }
    ]
  }