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

  task_role_arn = "arn:aws:iam::700060376888:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::700060376888:role/ecsTaskExecutionRole"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([{
    name: "nginx",
    image: "nginx",
    cpu: 0,
    portMappings: [
      {
          name: "nginx-80-tcp",
          containerPort: 80,
          hostPort: 80,
          protocol: "tcp",
          appProtocol: "http"
      }
    ],
    essential: true,
    environment: [],
    environmentFiles: [],
    mountPoints: [],
    volumesFrom: [],
    ulimits: [],
    logConfiguration: {
      logDriver: "awslogs",
      options: {
          awslogs-create-group: "true",
          awslogs-group: "/ecs/",
          awslogs-region: "eu-west-2",
          awslogs-stream-prefix: "ecs"
      },
      secretOptions: []
      }
    }
  ])
}

# resource "aws_security_group" "sg" {
#   vpc_id = data.aws_vpc.vpc.id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-sg"
#   }
# }

# resource "aws_iam_role" "ecs_task_execution_role" {
#   name               = "${local.formatted_name}_ECS_TaskExecutionRole"
#   assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
# }

# data "aws_iam_policy_document" "task_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# ########################################################################################################################
# ## IAM Role for ECS Task
# ########################################################################################################################

# resource "aws_iam_role" "ecs_task_iam_role" {
#   name               = "${local.formatted_name}_ECS_TaskIAMRole"
#   assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
# }

# resource "aws_ecs_task_definition" "ecs_task" {
#   family                   = "${var.project_name}-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "1024"
#   memory                   = "2048"

#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn      = aws_iam_role.ecs_task_iam_role.arn

#   runtime_platform {
#     operating_system_family = "LINUX"
#   }

#   container_definitions = jsonencode([{
#     name  = "test-e",
#     image = "700060376888.dkr.ecr.eu-west-2.amazonaws.com/fargate-nextjs-webapp-nginx:teste",
#     cpu = 1024
#     memory = 2048
#     essential = true
#     portMappings = [{
#       containerPort = 3000
#       hostPort = 3000
#       protocol      = "tcp"
#     }]
#   }])
# }

# resource "aws_alb" "alb" {
#   name            = "${var.project_name}-alb"
#   internal           = false
#   load_balancer_type = "application"

#   enable_deletion_protection = false

#   security_groups = [aws_security_group.sg.id]
#   subnets         = aws_subnet.public_subnet.*.id
# }

# resource "aws_alb_listener" "listener" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.example.arn
#   }
# }

# resource "aws_alb_target_group" "example" {
#   depends_on = [aws_alb.alb]

#   name        = "${var.project_name}-tg"
#   port        = var.container_port
#   protocol    = "HTTP"
#   deregistration_delay = 5
#   target_type = "ip"

#   vpc_id      = aws_vpc.vpc.id

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     interval            = 60
#     matcher             = 200
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = 30
#   }
# }