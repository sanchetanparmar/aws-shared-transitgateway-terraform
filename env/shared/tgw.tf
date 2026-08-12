// AWS Transit Gateway
module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name                                  = "${var.project}-${var.environment}-${var.tgw_name}"
  enable_auto_accept_shared_attachments = false

  vpc_attachments = {
    shared_vpc = {
      vpc_id      = module.vpc.vpc_id
      subnet_ids  = module.vpc.public_subnets
      dns_support = true
    }
  }
  amazon_side_asn = var.tgw_amazon_side_asn
  share_tgw       = true
  ram_allow_external_principals = true
  ram_principals = [
    "************", # Dev
    "*************" # Test
    # "222222222222",  # Account C ID
    # # Add more account IDs as needed
  ]

  tags = var.aws_tags
}
