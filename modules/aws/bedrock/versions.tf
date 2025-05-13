
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97.0" # Versión actualizada que soporta Bedrock Agent
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
  required_version = ">= 1.0.0"
}
