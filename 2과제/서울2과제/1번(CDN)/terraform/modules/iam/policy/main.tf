resource "aws_iam_policy" "policy" {
  name   = var.policy_name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = var.role_name
  policy_arn = aws_iam_policy.policy.arn
}
