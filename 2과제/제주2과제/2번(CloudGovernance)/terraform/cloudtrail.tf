resource "aws_cloudtrail" "cloud_trail" {
  depends_on = [aws_s3_bucket_policy.cloud_trail_bucket_policy]

  name = "cg-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloud_trail_bucket.id
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.cloud_trail_cloudwatch_role.arn
  include_global_service_events = true
  is_multi_region_trail = true
  enable_logging = true
}