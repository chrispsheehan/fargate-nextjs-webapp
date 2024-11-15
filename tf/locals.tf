locals {
  formatted_name         = replace(var.project_name, "-", "_")
  az_count               = min(length(data.aws_availability_zones.azs.names), var.max_az)
  cloudwatch_log_name    = "/ecs/${local.formatted_name}"
  static_secret_ssm_name = "/${local.formatted_name}/static_secret"
  container_definitions = templatefile("${path.module}/container_definitions.tpl", {
    container_name         = var.project_name
    image_uri              = data.aws_ecr_image.latest_image.image_uri
    container_port         = var.container_port
    cpu                    = var.cpu
    memory                 = var.memory,
    aws_region             = var.region,
    api_key_ssm_param_name = var.api_key_ssm_param_name,
    static_secret_ssm_arn  = aws_ssm_parameter.static_secret_ssm.arn
    cloudwatch_log_name    = local.cloudwatch_log_name
  })
}
 