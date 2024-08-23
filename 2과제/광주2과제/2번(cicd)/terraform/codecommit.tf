resource "aws_codecommit_repository" "argocd_app_repo" {
  repository_name = "gwangju-application-repo"
  default_branch = "main"
}

resource "aws_codecommit_repository" "argocd_cicd_repo" {
  repository_name = "arocd-cicd-repo"
  default_branch = "main"
}