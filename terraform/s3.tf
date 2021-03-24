#
# cache s3 bucket
#
resource "aws_s3_bucket" "codebuild-cache" {
  bucket = "test-automation-build-cache-${random_string.random.result}"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "test-automation" {
  bucket = "test-automation-${random_string.random.result}"
  acl    = "private"

  lifecycle_rule {
    id      = "clean-up"
    enabled = "true"

    expiration {
      days = 30
    }
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

