resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "wsc2024-gvn-LG"
}

resource "aws_cloudwatch_log_metric_filter" "cloudwatch_log_filter" {
  name = "employee_log_filter"
  pattern = "{ $.userIdentity.userName = Employee && $.eventName = AttachRolePolicy && $.requestParameters.roleName = wsc2024-instance-role }"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name

  metric_transformation {
    name = "employee_event_count"
    namespace = "log_filter"
    value = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm" {
  alarm_name = "wsc2024-gvn-alarm"
  metric_name = "employee_event_count"
  namespace = "log_filter"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  period = 10
  statistic = "Sum"
  threshold = 1
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_lambda_trigger" {
  name = "cloudwatch_lambda_trigger"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
  filter_pattern = "{ $.userIdentity.userName = Employee && $.eventName = AttachRolePolicy && $.requestParameters.roleName = wsc2024-instance-role }"
  destination_arn = aws_lambda_function.lambda_function.arn
}