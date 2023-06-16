terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # backend "s3"{
  #   bucket = "your-terraform-state-bucket"
  #   key = "folder/terraform.tfstate"
  #   region = "us-east-1"
  #   dynamodb_table = "your-terraform-terraform-statefile-locks"
  #   encrypt = true
  # }
}

provider "aws" {
  region = "us-east-1"
}