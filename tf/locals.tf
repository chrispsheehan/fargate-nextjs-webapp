locals {
  formatted_name = replace(var.project_name, "-", "_")
  az_count       = min(length(data.aws_availability_zones.azs.names), var.max_az)
  subnets = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr_block, 8, i)]
}
