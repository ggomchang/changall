resource "aws_ecs_task_definition" "app_task_definition" {
  family = "app"

  container_definitions = jsonencode([
    {
      name = "app"
      image = "${aws_ecr_repository.ecs_cicd_app_repo.repository_url}:latest"
      cpu = 0
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
          protocol = "tcp"
          appProtocol = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/app"
          awslogs-region = "us-west-1"
          awslogs-stream-prefix = "ecs"
          awslogs-create-group = "true",
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu = 512
  memory = 1024
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cicd_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [
    "FARGATE"
  ]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name = "ecs_service_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "ecs_service_sg"
  }
}

resource "aws_ecs_service" "app_service" {
  name = "app_service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  desired_count = 2
  launch_type = "FARGATE"
  force_new_deployment = true

  network_configuration {
    security_groups = [
      aws_security_group.ecs_service_sg.id
    ]
    subnets = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg_a.arn
    container_port = 8080
    container_name = "app"
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [
    aws_lb_listener.ecs_alb_listener,
    aws_ecs_task_definition.app_task_definition
  ]
}