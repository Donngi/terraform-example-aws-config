# ------------------------------------------------------------
# Config rule
# ------------------------------------------------------------

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3_bucket_public_read_prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

# ------------------------------------------------------------
# Remediation configuration
#
# NOTE: You can see all of SSM Sutomation runbook here
# https://docs.aws.amazon.com/ja_jp/systems-manager-automation-runbooks/latest/userguide/automation-runbook-reference.html
#
# NOTE: Terraform doesn't support automatic remediation at least v1.0.1
# ------------------------------------------------------------

resource "aws_config_remediation_configuration" "disable_s3_bucket_public_read_write" {
  config_rule_name = aws_config_config_rule.s3_bucket_public_read_prohibited.name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisableS3BucketPublicReadWrite"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.disable_s3_bucket_public_read_write.arn
  }
  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }
}

# ------------------------------------------------------------
# IAM Role - Automatic remediation
# ------------------------------------------------------------
resource "aws_iam_role" "disable_s3_bucket_public_read_write" {
  name = "AutoRemediationRoleDisableS3BucketPublicReadWrite"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole"
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
      }
    ]
  })
}

resource "aws_iam_policy" "disable_s3_bucket_public_read_write" {
  name = "${aws_iam_role.disable_s3_bucket_public_read_write.name}Policy"

  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "s3:PutBucketPublicAccessBlock"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "disable_s3_bucket_public_read_write" {
  role       = aws_iam_role.disable_s3_bucket_public_read_write.name
  policy_arn = aws_iam_policy.disable_s3_bucket_public_read_write.arn
}
