{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockKnowledgeBaseTrustPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "${aws_service}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:${region}:${account_id}:knowledge-base/*"
        }
      }
    }
  ]
}
