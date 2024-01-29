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

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "${var.project_name}-task-2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  task_role_arn      = data.aws_iam_role.ecs_task_role.arn
  execution_role_arn = data.aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name : "nginx",
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

resource "aws_security_group" "sg" {
  vpc_id = data.aws_vpc.vpc.id

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

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_ecs_service" "nginx" {
  depends_on = [aws_lb.lb]

  name                  = "${var.project_name}-service"
  launch_type           = "FARGATE"
  cluster               = aws_ecs_cluster.cluster.id
  task_definition       = aws_ecs_task_definition.nginx_task.arn
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
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_lb_target_group" "example" {
  depends_on = [aws_lb.lb]

  name     = "${var.project_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  target_type = "ip"
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb" "lb" {
  name               = "${var.project_name}-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = aws_subnet.public_subnet.*.id

  enable_deletion_protection = false
}