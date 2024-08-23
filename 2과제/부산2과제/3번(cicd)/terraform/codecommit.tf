resource "aws_codecommit_repository" "main" {
  repository_name = "wsi-repo"
  description     = "wsi"
  default_branch  = "main"
}