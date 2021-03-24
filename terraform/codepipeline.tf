#
# codepipeline - demo
#

resource "aws_codepipeline" "test-automation" {
  name     = "test-automation-pipeline"
  role_arn = "${aws_iam_role.test-automation-pipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.test-automation.bucket}"
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
      output_artifacts = ["SourceArtifact"]


      configuration = {
          Owner                = "OwnerName"
          Repo                 = "test-automation"
          Branch               = "master"
//        you can generate your OAuthToken from your code hosting platform (ex : GitHub)
          OAuthToken           = "xxxxxxxxxxxxxxxxxxx"

        }
    }
  }


  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["build"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.test-automation.name}"
      }
    }
  }

}


