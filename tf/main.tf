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
    "Name" = "${var.project_name}-internet-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.project_name}-public-routetable"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "public_subnet" {
  count = var.desired_count

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = local.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = var.desired_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet" {
  depends_on = [aws_subnet.public_subnet]

  count = var.desired_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = local.private_subnets[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

resource "aws_route_table_association" "private_association" {
  count          = var.desired_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_ecr_repository" "nginx" {
  name = "${var.project_name}-nginx"
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_security_group" "allow_all" {
  name        = "${local.formatted_name}_allow_all"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false

  security_groups = [aws_security_group.allow_all.id]
  subnets         = aws_subnet.public_subnet[*].id
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_target_group" "example" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/health"  # Replace with your health check path
    protocol            = "HTTP"
    port                = var.container_port
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "${var.project_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-container"
      image = "${aws_ecr_repository.nginx.repository_url}:${var.image_tag}"
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        },
      ]
    },
  ])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = replace("${var.project_name}_ecs_execution_role", "-", "_")

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_service" "fargate_service" {
  depends_on = [aws_lb.example, aws_lb_target_group.example]

  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.fargate_task.arn

  launch_type = "FARGATE"

  desired_count = var.desired_count

  network_configuration {
    subnets         = flatten([aws_subnet.private_subnet[*].id, aws_subnet.public_subnet[*].id])
    security_groups = [aws_security_group.allow_all.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "${var.project_name}-container"
    container_port   = var.container_port
  }
}
