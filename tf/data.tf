data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ecr_repository" "nginx" {
  name = "${var.project_name}-nginx"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
