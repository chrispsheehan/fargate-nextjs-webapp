resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_subnet" "public_subnet" {
  count = local.az_count

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = local.subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = local.az_count

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-ecs"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.formatted_name}_ecs_execution_role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "nginx",
    image = "${data.aws_ecr_repository.nginx.repository_url}:latest",
    portMappings = [{
      containerPort = 80,
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "fargate_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public_subnet.*.id
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }

  desired_count = 1
}

resource "aws_alb" "alb" {
  name            = "${var.project_name}-alb"
  security_groups = [aws_security_group.sg.id]
  subnets         = aws_subnet.public_subnet.*.id
}
