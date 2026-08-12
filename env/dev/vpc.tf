module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name             = "${var.project}-${var.environment}-${var.vpc_name}"
  cidr             = var.vpc_cidr
  azs              = var.vpc_az
  public_subnets   = var.vpc_public_subnets
  private_subnets  = var.vpc_private_subnets

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  enable_dns_hostnames   = var.vpc_enable_dns_hostnames

  tags = var.aws_tags
}
