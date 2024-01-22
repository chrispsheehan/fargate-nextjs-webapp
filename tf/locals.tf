locals {
    public_subnets = [for i in range(var.desired_count) : cidrsubnet(var.vpc_cidr_block, 8, i)]
    private_subnets = [for i in range(var.desired_count) : cidrsubnet(var.vpc_cidr_block, 8, i + var.desired_count)]
}
