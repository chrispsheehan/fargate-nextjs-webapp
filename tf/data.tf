data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_ecr_repository" "ecr" {
  name = var.project_name
}

data "aws_ecr_image" "latest_image" {
  repository_name = var.project_name
  most_recent     = true
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

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath"
    ]
    resources = [
      aws_ssm_parameter.api_key_ssm.arn,
      aws_ssm_parameter.static_secret_ssm.arn
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.ecs_log_group.arn}",
      "${aws_cloudwatch_log_group.ecs_log_group.arn}:*"
    ]
  }
}