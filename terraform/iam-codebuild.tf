#
# iam roles
#
resource "aws_iam_role" "test-automation-codebuild" {
  name = "test-automation-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "test-automation-codebuild" {
  role = aws_iam_role.test-automation-codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild-cache.arn}",
        "${aws_s3_bucket.codebuild-cache.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:List*",
        "s3:Put*",
        "s3:Get*"
      ],
      "Resource": [
        "${aws_s3_bucket.test-automation.arn}",
        "${aws_s3_bucket.test-automation.arn}/*"
      ]
    },
    {
      "Sid": "ECRPushPolicy",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "ECRAuthPolicy",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    }, 
    {
      "Sid": "ECS",
      "Effect": "Allow",
      "Action": [
        "ecs:List*",
        "ecs:Describe*"
      ],
      "Resource": [
        "*"
      ]
    }, 
    {
      "Effect": "Allow",
      "Action": [
         "kms:DescribeKey",
         "kms:GenerateDataKey*",
         "kms:Encrypt",
         "kms:ReEncrypt*",
         "kms:Decrypt"
        ],
      "Resource": [
         "${aws_kms_key.test-automation.arn}"
        ]
    }
  ]
}
POLICY

}

