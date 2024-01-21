resource "aws_ecr_repository" "ecr" {
  name = "${var.project-name}-ecr"
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.project-name}-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project-name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = var.container-name
    image = aws_ecr_repository.ecr.repository_url
  }])
}

resource "aws_ecs_service" "service" {
  name            = "${var.project-name}-service"
  cluster         = "default"
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  #   network_configuration {
  #     subnets = ["subnet-xxxxxxxxxxxxxxxxx"]  # Replace with your subnet ID
  #     security_groups = ["sg-xxxxxxxxxxxxxxxxx"]  # Replace with your security group ID
  #   }
}