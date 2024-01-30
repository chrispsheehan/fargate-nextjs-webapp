locals {
  formatted_name = replace(var.project_name, "-", "_")
  az_count       = min(length(data.aws_availability_zones.azs.names), var.max_az)
  container_definitions = templatefile("${path.module}/container_definitions.tpl", {
    container_name = var.project_name
    image_uri = "${data.aws_ecr_repository.ecr.repository_url}:${var.image_tag}"
    container_port = var.container_port
    host_port = var.host_port
  })
}