output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

# output "transit_gateway_id" {
#   value = module.tgw.ec2_transit_gateway_id
# }

# output "transit_gateway_arn" {
#   value = module.tgw.ec2_transit_gateway_arn
# }

output "vpc_cidr" {
  value = var.vpc_cidr
}


# output "ecr" {
#   value = module.ecr
# }