locals {
  fargate_task_definition = templatefile("${path.module}/bin/fargate_task_definition.json.tpl", {
    task_family     = "${var.project-name}-task",
    container_name  = "${var.project-name}-container",
    container_image = var.container-image,
    cpu             = var.cpu,
    memory          = var.memory,
    container_port  = var.container-port,
    host_port       = var.host_port,
  })
}
