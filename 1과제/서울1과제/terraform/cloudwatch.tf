resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = "/aws/vpc/wsi-vpc"
}