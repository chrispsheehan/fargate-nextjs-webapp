data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

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
