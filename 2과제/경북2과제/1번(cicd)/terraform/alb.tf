resource "aws_security_group" "ecs_alb_sg" {
  name = "wsi_alb_sg"
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
    Name = "wsi_alb_sg"
  }
}

resource "aws_lb" "ecs_alb" {
  name = "wsi-alb-ci"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.ecs_alb_sg.id
  ]
  subnets = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

resource "aws_lb_target_group" "ecs_alb_tg_a" {
  name = "wsi-alb-tg-a"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "ecs_alb_tg_b" {
  name = "wsi-alb-tg-b"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg_a.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}