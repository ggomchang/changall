resource "aws_dynamodb_table" "table" {
  name         = "serverless-user-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "serverless-user-table"
  }
}
