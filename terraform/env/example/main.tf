module "config" {
  source = "../../module/config"
}

module "rule_aws_managed_rule_s3_bucket_public_read_prohibited" {
  source     = "../../module/rule_aws_managed_rule_s3_bucket_public_read_prohibited"
  depends_on = [module.config]
}

module "rule_custom_rule_iam_user_no_exist_check" {
  source     = "../../module/rule_custom_rule_iam_user_no_exist_check"
  depends_on = [module.config]
}
