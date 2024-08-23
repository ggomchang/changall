resource "aws_ecr_repository" "customer" {
  name = "customer-ecr"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "product" {
  name = "product-ecr"
  force_delete = true
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "order" {
  name = "order-ecr"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}