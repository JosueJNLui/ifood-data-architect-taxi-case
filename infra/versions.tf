terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}
