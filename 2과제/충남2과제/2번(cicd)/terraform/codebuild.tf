data "aws_caller_identity" "current" {}

resource "aws_codebuild_project" "codebuild" {
  name = "wsc2024-cbd"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"
    ]
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yaml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    privileged_mode = true
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.ecs_cicd_app_repo.name}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-west-1"
    }
  }

  depends_on = [
    aws_codecommit_repository.codecommit
  ]
}