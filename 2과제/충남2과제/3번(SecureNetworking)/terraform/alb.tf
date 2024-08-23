resource "aws_security_group" "alb_sg" {
  name = "gm-alb-sg"
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
    Name = "gm-alb-sg"
  }
}

resource "aws_lb" "alb" {
  name = "gm-alb"
  load_balancer_type = "application"
  internal = true

  security_groups = [
    aws_security_group.alb_sg.id
  ]
  subnets = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name = "gm-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name = "gm-tg"
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

  tags = {
    Name = "gm-tg"
  }
}

resource "aws_lb_listener" "wsi_alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_target_group_attachment" "wsi_alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id = aws_instance.bastion_ec2.id
  port = 5000
}