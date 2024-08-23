resource "aws_iam_role" "role" {
  name = var.role_name
  assume_role_policy = var.role_policy
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  role = aws_iam_role.role.name
  policy_arn = var.policy_arn
}