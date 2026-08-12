terraform {
  backend "s3" {
    bucket  = "terraform-tfstate"
    key     = "dev/terraform.tfstate"
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
  alias  = "shared"
  region = var.aws_region
}


provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/terraform_role"
    session_name = "terraform-automation"
   }
}

data "terraform_remote_state" "terraform" {
  backend = "s3"
  config = {
    bucket               = var.main_tf_backend.bucket
    key                  = var.main_tf_backend.key
    region               = var.main_tf_backend.region
    # workspace_key_prefix = local.main_tf_backend.workspace_key_prefix
  }
}