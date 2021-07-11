# ------------------------------------------------------------
# Lambda
# ------------------------------------------------------------

data "archive_file" "iam_user_no_exist_check" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/upload/lambda.zip"
}

resource "aws_lambda_function" "iam_user_no_exist_check" {
  filename      = data.archive_file.iam_user_no_exist_check.output_path
  function_name = "ConfigRuleIamUserNoExistCheck"
  role          = aws_iam_role.lambda.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.iam_user_no_exist_check.output_base64sha256

  runtime = "python3.8"

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      iam_user_no_exist_check_ENV = "iam_user_no_exist_check_VALUE"
    }
  }

  timeout = 30
  publish = true
}

resource "aws_lambda_permission" "iam_user_no_exist_check" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_user_no_exist_check.arn
  principal     = "config.amazonaws.com"
}

# ------------------------------------------------------------
# IAM Role for Lambda
# ------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "LambdaConfigRuleIamUserNoExistCheckRole"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

# Basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# List IAM users
resource "aws_iam_policy" "lambda_list_iam_users" {
  name = "ListIAMUsersPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "iam:ListUsers"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_list_iam_users" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_list_iam_users.arn
}

# Config put evaluation
resource "aws_iam_policy" "lambda_config_put_evaluation" {
  name = "ConfigPutEvaluationPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "config:PutEvaluations"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_config_put_evaluation" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_config_put_evaluation.arn
}
