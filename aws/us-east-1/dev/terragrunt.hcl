# aws/us-east-1/dev/terragrunt.hcl
locals {
  tenant      = "la"  # am | na | la
  environment = "dev" # prd | qa | dev | sbx | drp |
  account_id  = "745315529340"
  folder      = "dev"
  global      = yamldecode(file(find_in_parent_folders("us-east-1.yaml")))
  module      = "${local.global.repo_name}/${local.global.path}/${local.folder}"

  secrets = yamldecode(sops_decrypt_file(find_in_parent_folders("us-east-1-id.yaml")))

  extra_atlantis_dependencies = [
    "${find_in_parent_folders()}/us-east-1.yaml",
    "${find_in_parent_folders()}/us-east-1-id.yaml"
  ]
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    region         = "${local.global.aws_region}"
    key            = "${local.module}/${path_relative_to_include()}/terraform.tfstate"
    bucket         = "${local.global.state_bucket}"
    kms_key_id     = "${local.global.kms_key_s3}"
    dynamodb_table = "${local.global.state_table}"
    encrypt        = true
    assume_role = {
      role_arn    = local.global.state_iam_arn
      external_id = local.secrets.tfstate_id
    }
  }
}

generate "commons" {
  path      = "commons.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "${local.global.aws_region}"
}

variable "account_id" {
  description = "AWS account id"
  type        = string
  default     = "${local.account_id}"
}

variable "tf_role" {
  description = "Role used to access other accounts"
  type        = string
  default     = "${local.global.trust_role}"
}

variable "external_id" {
  description = "External Id to assume the role"
  type        = string
  default     = "${local.global.external_id}"
  sensitive   = true
}

variable "author" {
  description = "Name of the last user that apply changes"
  type        = string
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= ${local.global.aws_version}"
    }
  }

  required_version = ">= ${local.global.tf_min_ver}"
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.global.aws_region}"

  default_tags {
    tags = {
      deploy-by = var.author
      tf-state  = "${local.module}/${path_relative_to_include()}"
    }
  }

  assume_role {
    role_arn     = join("", ["arn:aws:iam::", var.account_id, ":role/", var.tf_role])
    session_name = var.author
    external_id  = var.external_id
  }

  allowed_account_ids = ["${local.account_id}"]

  skip_credentials_validation = true
}
EOF
}

inputs = {
  tenant      = local.tenant
  environment = local.environment
  namespace   = local.global.namespace
  project     = local.global.project
  cost_center = local.global.cost_center
  sla_tier    = local.global.sla_tier
  app_name    = local.global.app_name
  app_type    = local.global.app_type
}
