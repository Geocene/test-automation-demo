# code build
resource "aws_codebuild_project" "test-automation" {
  name           = "test-automation"
  build_timeout  = "30"
  service_role   = "${aws_iam_role.test-automation-codebuild.arn}"
  encryption_key = "${aws_kms_alias.test-automation.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_REGION
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.test-automation.name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

}

