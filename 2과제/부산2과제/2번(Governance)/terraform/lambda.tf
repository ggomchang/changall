resource "aws_lambda_function" "lambda_function" {
  function_name = "wsi-project-log-function"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "./lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  timeout       = 60

  environment {
    variables = {
      TZ                = "Asia/Seoul"
    }
  }
  tags = {
    Name = "wsi-project-log-function"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  principal     = "logs.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
}