terraform {
  backend "s3" {
    bucket  = "terraform-tfstate"
    key     = "shared/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    use_lockfile = true
  }
}

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}
