resource "aws_cloudwatch_log_group" "customer_log_group" {
  name = "/wsi/webapp/customer"
  kms_key_id = aws_kms_key.cloudwatch_cmk.arn

  depends_on = [
    aws_kms_key_policy.cloudwatch_cmk_policy
  ]
}

resource "aws_cloudwatch_log_group" "product_log_group" {
  name = "/wsi/webapp/product"
  kms_key_id = aws_kms_key.cloudwatch_cmk.arn

  depends_on = [
    aws_kms_key_policy.cloudwatch_cmk_policy
  ]
}

resource "aws_cloudwatch_log_group" "order_log_group" {
  name = "/wsi/webapp/order"
  kms_key_id = aws_kms_key.cloudwatch_cmk.arn

  depends_on = [
    aws_kms_key_policy.cloudwatch_cmk_policy
  ]
}
