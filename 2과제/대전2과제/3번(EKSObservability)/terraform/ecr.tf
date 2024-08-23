resource "aws_ecr_repository" "ecr" {
  name = "daejeon-eks-logging-ecr"
  force_delete = true
}