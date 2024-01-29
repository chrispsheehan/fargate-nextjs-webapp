locals {
  formatted_name = replace(var.project_name, "-", "_")
  az_count       = min(length(data.aws_availability_zones.azs.names), var.max_az)
}