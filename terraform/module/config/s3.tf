# ------------------------------------------------------------
# S3 bucket
# ------------------------------------------------------------

resource "aws_s3_bucket" "config" {
  bucket = "sample-aws-config-bucket-${data.aws_caller_identity.current.id}"
  acl    = "private"
}

# ------------------------------------------------------------
# Block public access
# ------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------
# Bucket policy
# ------------------------------------------------------------

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSConfigBucketPermissionsCheck",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "config.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : aws_s3_bucket.config.arn
      },
      {
        "Sid" : "AWSConfigBucketExistenceCheck",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "config.amazonaws.com"
        },
        "Action" : "s3:ListBucket",
        "Resource" : aws_s3_bucket.config.arn
      },
      {
        "Sid" : "AWSConfigBucketDelivery",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "config.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.id}/Config/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
