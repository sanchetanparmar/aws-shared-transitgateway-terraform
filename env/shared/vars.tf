variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "main_tf_backend" {
  description = "Backend configuration for the shared tf state."
  type = object({
    bucket = string
    key    = string
    region = string
  })
  default = {
    bucket = "terraform-tfstate"
    key    = "shared/terraform.tfstate"
    region = "eu-central-1"
  }
}

variable "project" {
  description = "Project name."
  type        = string
  default     = "myproject"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "shared"
}

variable "tgw_name" {
  description = "TGW name built in this format: project-environment-tgw_name."
  type        = string
  default     = "tgw"
}

variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN for TGW."
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "VPC name."
  type        = string
  default     = "shared-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.150.0.0/16"
}

variable "vpc_az" {
  description = "List of availability zones."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDRs."
  type        = list(string)
  default     = ["10.150.0.0/24", "10.150.1.0/24"]
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDRs."
  type        = list(string)
  default     = []
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway."
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Use a single NAT gateway."
  type        = bool
  default     = true
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Use one NAT gateway per AZ."
  type        = bool
  default     = false
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC."
  type        = bool
  default     = true
}

variable "aws_tags" {
  description = "AWS resource tags."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
