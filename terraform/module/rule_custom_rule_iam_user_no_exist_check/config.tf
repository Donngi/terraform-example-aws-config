# ------------------------------------------------------------
# Config rule
# ------------------------------------------------------------

resource "aws_config_config_rule" "iam_user_no_exist_check" {
  name        = "iam_user_no_exist_check"
  description = "Check if any IAM users are exist in the account."

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.iam_user_no_exist_check.arn
    source_detail {
      message_type = "ScheduledNotification"
    }
  }

  input_parameters = jsonencode({
    "unaudited_users" : [
      "sample-user-A",
      "sample-user-B",
    ]
  })
}
