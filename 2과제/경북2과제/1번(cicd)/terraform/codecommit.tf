resource "aws_codecommit_repository" "codecommit" {
  repository_name = "wsi-commit"
  default_branch = "main"
}