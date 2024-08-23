resource "aws_ecr_repository" "eks_cicd_ecr" {
  name = "eks-cicd-ecr"
  force_delete = true
}