resource "aws_ecr_repository" "token_repo" {
  name = "token"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "employee_repo" {
  name = "employee"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"
}