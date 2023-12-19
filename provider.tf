terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    archive = "~> 1.3"
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY


  default_tags {
    tags = {
      env         = var.env
      provider    = var.tf_provider
      platform    = var.platform
      application = var.application
      cost-center = var.cost_center
      owner       = var.owner
      lob         = var.lob
    }
  }
}
