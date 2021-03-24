#
# kms
#
data "aws_iam_policy_document" "test-automation-kms-policy" {
  policy_id = "key-default-1"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_kms_key" "test-automation" {
  description = "kms key for demo artifacts"
  policy      = data.aws_iam_policy_document.test-automation-kms-policy.json
}

resource "aws_kms_alias" "test-automation" {
  name          = "alias/test-automation"
  target_key_id = aws_kms_key.test-automation.key_id
}


