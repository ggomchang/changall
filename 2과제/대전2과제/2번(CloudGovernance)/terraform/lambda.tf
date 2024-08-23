resource "aws_lambda_function" "lambda_function" {
  function_name = "ec2-port-delete"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "./lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  timeout       = 180

  environment {
    variables = {
      SECURITY_GROUP_ID = aws_security_group.bastion_sg.id
      INSTANCE_ID       = aws_instance.bastion_ec2.id
      TZ                = "Asia/Seoul"
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  principal     = "config.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
}
