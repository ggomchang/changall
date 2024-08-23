resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "/ec2/deny/port"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name = "deny-${aws_instance.bastion_ec2.id}"

  depends_on = [
    aws_instance.bastion_ec2
  ]
}