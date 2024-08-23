resource "aws_dynamodb_table" "order_table" {
  name = "order"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key = "id"

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "order"
  }

  depends_on = [
    aws_kms_key.dynamodb_cmk
  ]
}