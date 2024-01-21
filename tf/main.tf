resource "aws_vpc" "vpc" {
  cidr_block           = var.custom-vpc
  instance_tenancy     = var.instance-tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = aws_vpc.vpc.cidr_block
  map_public_ip_on_launch = true
}
resource "aws_security_group" "fargate-sq" {
  name   = "Farget nextjs Security Group"
  vpc_id = aws_vpc.vpc.id

  egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "ecr" {
  name = "${var.project-name}-ecr"
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.project-name}-ecs"
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

  container_definitions = jsonencode([
    {
      name  = "${var.project-name}-app"
      image = "${var.container-image}"
    }
  ])

}

resource "aws_ecs_service" "service" {
  name            = "${var.project-name}-service"
  cluster         = aws_ecs_cluster.ecs.name
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.fargate-sq.id]
  }
}