data "aws_caller_identity" "me" {}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${data.aws_caller_identity.me.account_id}"
  force_destroy = true
}

resource "aws_iam_role" "pipeline" {
  name = "${var.project_name}-codepipeline"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{Effect="Allow",Principal={Service="codepipeline.amazonaws.com"},Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy_attachment" "pipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild"
  assume_role_policy = jsonencode({
    Version="2012-10-17", Statement=[{Effect="Allow",Principal={Service="codebuild.amazonaws.com"},Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_codebuild_project" "build" {
  name         = "${var.project_name}-build"
  service_role = aws_iam_role.codebuild.arn
  artifacts { type = "CODEPIPELINE" }
  environment {
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/standard:7.0"
    compute_type = "BUILD_GENERAL1_SMALL"
    privileged_mode = true
  }
  source { type = "CODEPIPELINE" }
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.pipeline.arn
  artifact_store { 
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket 
  }

  stage {
    name = "Source"
    action {
      name="GitHub"
      category="Source"
      owner="AWS"
      provider="CodeStarSourceConnection"
      version="1"
      output_artifacts=["source_output"]
      configuration = {
        ConnectionArn   = var.codestar_connection_arn
        FullRepositoryId= "${var.github_owner}/${var.github_repo}"
        BranchName      = var.github_branch
        DetectChanges   = "true"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name="CodeBuild"
      category="Build"
      owner="AWS"
      provider="CodeBuild"
      version="1"
      input_artifacts=["source_output"]
      output_artifacts=["build_output"]
      configuration = { ProjectName = aws_codebuild_project.build.name }
    }
  }

  stage {
    name = "Deploy"
    action {
      name="DeployToEB"
      category="Deploy"
      owner="AWS"
      provider="ElasticBeanstalk"
      version="1"
      input_artifacts=["build_output"]
      configuration = { ApplicationName = var.eb_app_name, EnvironmentName = var.eb_env_name }
    }
  }
}
