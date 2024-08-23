resource "aws_lambda_function" "lambda_function" {
  function_name = "wsc2024-gvn-Lambda"
  runtime = "python3.9"
  role = aws_iam_role.lambda_role.arn
  filename = "./deletePolicy.zip"
  handler = "deletePolicy.lambda_handler"
  timeout = 60
}

resource "aws_lambda_permission" "lambda_permission" {
  principal = "logs.amazonaws.com"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  source_arn = "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}:*"
}