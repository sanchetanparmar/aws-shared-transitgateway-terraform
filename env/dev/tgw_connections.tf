resource "aws_ram_resource_share" "tgw_share" {
  provider = aws.shared
  name = "${module.vpc.name}-tgw-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "dev_account" {
  provider = aws.shared
  principal          = var.account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_resource_association" "tgw" {
  provider = aws.shared
  resource_arn       = data.terraform_remote_state.terraform.outputs.transit_gateway_arn
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  share_arn = aws_ram_principal_association.dev_account.resource_share_arn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = data.terraform_remote_state.terraform.outputs.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  tags = {
    Name = "${var.environment}-to-shared-tgw"
  }
  depends_on = [
    aws_ram_resource_association.tgw,
    aws_ram_principal_association.dev_account,
    aws_ram_resource_share_accepter.receiver_accept
  ]
}

// route table creation for tgw subnets
# resource "aws_route_table" "tgw" {
#   vpc_id = module.vpc.vpc_id
#   route {
#     cidr_block         = "0.0.0.0/0"
#     transit_gateway_id = data.terraform_remote_state.terraform.outputs.transit_gateway_id
#   }

#   tags = {
#     Name = "${var.environment}-${var.project}-${var.vpc_name}-rt-tgw"
#   }
# }

# // route table association for tgw subnets
# resource "aws_route_table_association" "tgw" {
#   for_each = toset(local.all_subnet_ids_private)

#   subnet_id = each.key
#   route_table_id = aws_route_table.tgw.id
# }

