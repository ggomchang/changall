resource "aws_codepipeline" "codepipeline" {
  name = "wsc2024-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.codepipeline_s3_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = 1
      output_artifacts = ["source_output"]
      namespace = "changgom"
      run_order = 1

      configuration = {
        RepositoryName = aws_codecommit_repository.argocd_app_repo.repository_name
        BranchName = aws_codecommit_repository.argocd_app_repo.default_branch
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version = 1
      run_order = 2

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
}