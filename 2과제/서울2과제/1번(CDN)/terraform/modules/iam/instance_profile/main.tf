resource "aws_iam_instance_profile" "role_instance_profile" {
  name = var.instance_profile_name
  role = var.role_name
}