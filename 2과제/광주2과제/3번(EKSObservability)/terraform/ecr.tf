resource "aws_ecr_repository" "ecr_a" {
  name = "eks-logging-ecr-a"
  force_delete = true
}

resource "aws_ecr_repository" "ecr_b" {
  name = "eks-logging-ecr-b"
  force_delete = true
}

resource "aws_ecr_repository" "ecr_c" {
  name = "eks-logging-ecr-c"
  force_delete = true
}