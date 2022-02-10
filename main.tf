terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider and here we are passing default tag to each resource.
provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}
