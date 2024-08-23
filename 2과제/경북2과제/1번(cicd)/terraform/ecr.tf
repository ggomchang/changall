resource "aws_ecr_repository" "ecs_cicd_app_repo" {
  name = "ecs-cicd-app-repo"
  force_delete = true
}