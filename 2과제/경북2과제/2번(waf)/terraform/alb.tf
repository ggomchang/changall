resource "aws_security_group" "wsi_alb_sg" {
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

resource "aws_lb" "wsi_alb" {
  name = "wsi-alb"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.wsi_alb_sg.id
  ]
  subnets = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]

  tags = {
    Name = "wsi-alb"
  }
}

resource "aws_lb_target_group" "wsi_alb_tg" {
  name = "wsi-alb-tg"
  port = 5000
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path                = "/healthcheck"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "wsi_alb_listener" {
  load_balancer_arn = aws_lb.wsi_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.wsi_alb_tg.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_target_group_attachment" "wsi_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.wsi_alb_tg.arn
  target_id = aws_instance.app_ec2.id
  port = 5000
}