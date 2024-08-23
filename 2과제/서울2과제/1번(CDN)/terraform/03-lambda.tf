module "resizing_lambda_function" {
  source = "./modules/lambda"

  function_name = "wsi-resizing-function"
  runtime = "nodejs20.x"
  role_arn = module.resize_role.role_arn
  filename = "resizing_function.zip"
  handler = "index.handler"

  providers = {
    aws = aws.virginia
  }
}