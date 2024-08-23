resource "aws_iam_role" "tgw_instance_role" {
  name = "tgw-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tgw_instance_role_attachment" {
  role = aws_iam_role.tgw_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "tgw_instance_profile" {
  name = "tgw_instance_profile"
  role = aws_iam_role.tgw_instance_role.name
}