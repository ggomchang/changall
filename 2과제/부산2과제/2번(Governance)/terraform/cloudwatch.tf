resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "wsi-project-login"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log-stream" {
  name           = "wsi-project-login-stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
}

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "cloudtrail-log-group"
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_trigger" {
  name = "lambda_trigger"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  destination_arn = aws_lambda_function.lambda_function.arn
  filter_pattern = "{ $.userIdentity.type=IAMUser && $.userIdentity.userName=wsi-project-user && $.responseElements.ConsoleLogin=Success }"
}