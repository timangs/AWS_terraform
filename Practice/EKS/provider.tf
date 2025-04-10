# providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a compatible version
    }
  }
}

provider "aws" {
  region = var.target_region
  # Configure AWS credentials using environment variables, shared credential file, or IAM role.
  # Avoid hardcoding access keys here.
  # access_key = var.my_iam_user_access_key_id # Not recommended
  # secret_key = var.my_iam_user_secret_access_key # Not recommended
}
