# =============================================================================
# OMNIBOT AWS - ARQUITECTURA SENIOR
# =============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "OmniBot"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Senior-DevOps"
    }
  }
}

# Data sources para obtener información de AWS
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}