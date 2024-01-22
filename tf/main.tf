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

resource "aws_subnet" "private_subnet" {
  depends_on = [ aws_subnet.public_subnet ]
  
  count = var.desired_count

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = local.private_subnets[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

resource "aws_ecr_repository" "ecr" {
  name = "${var.project_name}-ecr"
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_security_group" "sg" {
  name        = "CustomSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
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
    from_port   = var.container_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Load balancer security group"
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
      image = var.container_image
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
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.fargate_task.arn

  launch_type = "FARGATE"

  desired_count = var.desired_count

  network_configuration {
    subnets = aws_subnet.private_subnet[*].id
  }
}

resource "aws_lb" "app" {
  name               = "${var.project_name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets = aws_subnet.public_subnet[*].id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app.arn
  port              = var.container_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.project_name}-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "ecs" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_ecs_task_definition.fargate_task.arn
  port             = var.container_port
}
