resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  runtime = var.runtime
  role = var.role_arn
  filename = var.filename
  handler = var.handler
  timeout = 5
  publish = true

}

resource "aws_lambda_permission" "lambda_permission" {
  principal     = "logs.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
}