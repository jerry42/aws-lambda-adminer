terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }

  backend "s3" {
    bucket = "ug-terraform-state-file"
    key    = "adminer/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"
}

locals {
  tags = {
    Project = "adminer"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
