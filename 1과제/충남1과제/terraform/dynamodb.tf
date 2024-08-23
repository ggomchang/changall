resource "aws_dynamodb_table" "order_table" {
  name = "order"
  billing_mode   = "PROVISIONED"
  read_capacity = 20
  write_capacity = 20
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "order"
  }
}