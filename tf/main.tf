resource "aws_route_table" "rt" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_subnet" "public_subnet" {
  count = local.az_count

  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, local.az_count + count.index)


  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

resource "aws_route_table_association" "public_association" {
  count = local.az_count

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.rt.id
}

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = data.aws_vpc.vpc.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecr_repository" "ecr" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_security_group" "sg" {
  vpc_id = data.aws_vpc.vpc.id
  name = "${var.project_name}-sg"

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

resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false

  security_groups = [aws_security_group.sg.id]
  subnets         = aws_subnet.public_subnet[*].id
}

resource "aws_lb_target_group" "tg" {
  depends_on = [aws_lb.lb]

  name     = "${var.project_name}-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  target_type = "ip"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  task_role_arn      = data.aws_iam_role.ecs_task_role.arn
  execution_role_arn = data.aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

    # image : "${aws_ecr_repository.ecr.repository_url}:${var.image_tag}",

  container_definitions = jsonencode([{
    name : "nextjs-app",
    image : "nginx",
    cpu : 0,
    portMappings : [
      {
        name : "nginx-80-tcp",
        containerPort : 80,
        hostPort : 80,
        protocol : "tcp",
        appProtocol : "http"
      }
    ],
    essential : true,
    environment : [],
    environmentFiles : [],
    mountPoints : [],
    volumesFrom : [],
    ulimits : [],
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        awslogs-create-group : "true",
        awslogs-group : "/ecs/",
        awslogs-region : "${var.region}",
        awslogs-stream-prefix : "ecs"
      },
      secretOptions : []
    }
    }
  ])
}

resource "aws_ecs_service" "ecs" {
  depends_on = [aws_lb.lb]

  name                  = var.project_name
  launch_type           = "FARGATE"
  cluster               = aws_ecs_cluster.cluster.id
  task_definition       = aws_ecs_task_definition.task.arn
  desired_count         = var.desired_count
  wait_for_steady_state = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = aws_subnet.public_subnet.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "${var.project_name}"
    container_port   = var.container_port
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "${var.container_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
