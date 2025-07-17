terraform {
  required_version = ">=1.12.2"
  required_providers {
    aws = {
      version = ">=6.2.0"
      source  = "hashicorp/aws"
    }
  }
}