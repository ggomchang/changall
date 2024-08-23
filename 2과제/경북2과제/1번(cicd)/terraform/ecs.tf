resource "aws_ecs_task_definition" "app_task_definition" {
  family = "app"

  container_definitions = jsonencode([
    {
      name = "app"
      image = "${aws_ecr_repository.ecs_cicd_app_repo.repository_url}:latest"
      cpu = 0
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol = "tcp"
          appProtocol = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/app"
          awslogs-region = "ap-northeast-2"
          awslogs-stream-prefix = "ecs"
          awslogs-create-group = "true",
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = [
    "EC2"
  ]
  cpu = 512
  memory = 1024
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "wsi-ecs"
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

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "ecs_ec2_launch_template" {
  name_prefix            = "ecs-cicd-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.ecs_service_sg.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name_prefix               = "ecs-cicd-"
  vpc_zone_identifier = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-cicd"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "custom-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 2
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    base              = 1
    weight            = 100
  }

  depends_on = [
    aws_ecs_capacity_provider.ecs_capacity_provider
  ]
}

resource "aws_ecs_service" "app_service" {
  name = "wsi-ecs-s"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  desired_count = 2
  launch_type = "EC2"
  force_new_deployment = true

  network_configuration {
    security_groups = [
      aws_security_group.ecs_service_sg.id
    ]
    subnets = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg_a.arn
    container_port = 80
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