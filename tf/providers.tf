terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      version = ">= 4.15.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "chrispsheehan-fargate-nextjs-webapp-tfstate"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "chrispsheehan-fargate-nextjs-webapp-tf-lockid"
  }
}

provider "aws" {
  region = var.region
}
