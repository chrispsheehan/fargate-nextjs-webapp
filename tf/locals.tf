locals {
  formatted_name  = replace(var.project_name, "-", "_")
  public_subnets  = [for i in range(var.desired_count) : cidrsubnet(var.vpc_cidr_block, 8, i)]
}
