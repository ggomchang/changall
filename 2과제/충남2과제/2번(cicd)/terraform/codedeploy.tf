resource "aws_codedeploy_app" "codedeploy" {
  name = "wsc2024-cdy"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "codedeploy_group" {
  app_name = aws_codedeploy_app.codedeploy.name
  deployment_group_name = aws_codedeploy_app.codedeploy.name
  service_role_arn = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.app_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.ecs_alb_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.ecs_alb_tg_a.name
      }

      target_group {
        name = aws_lb_target_group.ecs_alb_tg_b.name
      }
    }
  }
}