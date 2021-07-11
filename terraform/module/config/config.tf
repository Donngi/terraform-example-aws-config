# ------------------------------------------------------------
# Recorder
# ------------------------------------------------------------

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

# ------------------------------------------------------------
# Delivery channel
# ------------------------------------------------------------
resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.default]
}

# ------------------------------------------------------------
# Recorder status
# ------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}