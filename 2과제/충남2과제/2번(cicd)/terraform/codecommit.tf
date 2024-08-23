resource "aws_codecommit_repository" "codecommit" {
  repository_name = "wsc2024-cci"
  default_branch = "master"
}