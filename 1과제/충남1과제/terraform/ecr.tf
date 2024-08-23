resource "aws_ecr_repository" "customer_repo" {
  name = "customer-repo"
  force_delete = true
}

resource "aws_ecr_repository" "product_repo" {
  name = "product-repo"
  force_delete = true
}

resource "aws_ecr_repository" "order_repo" {
  name = "order-repo"
  force_delete = true
}