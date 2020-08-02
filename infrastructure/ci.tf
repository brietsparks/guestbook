resource "aws_s3_bucket" "guestbook_ci" {
  bucket = "guestbook-ci"
  acl    = "private"
}

resource "aws_ecr_repository" "guestbook" {
  name                 = "guestbook"
  image_scanning_configuration {
    scan_on_push = true
  }
}

//resource "aws_codebuild_source_credential" "guestbook_ci" {
//  auth_type = "PERSONAL_ACCESS_TOKEN"
//  server_type = "GITHUB"
//  token = var.github_personal_access_token
//}

resource "aws_codepipeline" "guestbook_ci" {
  name     = "guestbook_ci"
  role_arn = aws_iam_role.guestbook_ci_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.guestbook_ci.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner  = var.github_repo_owner
        Repo   = var.github_repo_name

        // in a team, you would want to store the token in SSM and get the value from there
        // see: https://github.com/terraform-providers/terraform-provider-aws/issues/2796
        OAuthToken = var.github_oauth_token
        Branch = "ci"
      }
    }
  }

  stage {
    name = "Build"

    // https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeBuild.html
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "guestbook_ci"
      }
    }
  }

  //  stage {
  //    name = "Deploy"
  //
  //    action {
  //      name            = "Deploy"
  //      category        = "Deploy"
  //      owner           = "AWS"
  //      provider        = "CloudFormation"
  //      input_artifacts = ["build_output"]
  //      version         = "1"
  //
  //      configuration = {
  //        ActionMode     = "REPLACE_ON_FAILURE"
  //        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
  //        OutputFileName = "CreateStackOutput.json"
  //        StackName      = "MyStack"
  //        TemplatePath   = "build_output::sam-templated.yaml"
  //      }
  //    }
  //  }
}

resource "aws_codebuild_project" "guestbook_ci" {
  name          = "guestbook_ci"
  build_timeout = "8"
  service_role  = aws_iam_role.guestbook_ci_codebuild.arn

  source {
    type            = "CODEPIPELINE"
    buildspec       = var.server_buildspec_path
  }

  artifacts {
    type            = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source_version = "master"

  vpc_config {
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.private_subnets
    security_group_ids = [aws_security_group.guestbook_ci_codebuild.id]
  }
}

// todo: traffic rules with minimum scope
resource "aws_security_group" "guestbook_ci_codebuild" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
