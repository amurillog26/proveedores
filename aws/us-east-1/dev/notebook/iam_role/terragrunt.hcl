terraform {
  source = "git::gitlab.com:mycompany-org/americas-core/tools/tf-modules.git//aws/iamrole_6.1.0"
}

inputs = {
  name             = "pocp2pnotebook"
  role_description = "IAM Role for SageMaker Notebook"

  # Path (local, relativo a la carpeta actual "iam_role/") 
  assume_role_file_path = "${path.module}/policies/assume-role.tftpl"

  iam_policies = {
    custom_s3_access = {
      name               = "sagemaker-s3-access"
      description        = "S3 read from input-bucket, write to output-bucket"
      template_file_path = "${path.module}/policies/custom-policy.tftpl"
      template_vars = {
        vars = {
          input_bucket_arn  = "arn:aws:s3:::lhlanonp-providerp2p-input"
          output_bucket_arn = "arn:aws:s3:::lhlanonp-providerp2p-output"
        }
      }
      use_custom_name = true
    }
  }
}
