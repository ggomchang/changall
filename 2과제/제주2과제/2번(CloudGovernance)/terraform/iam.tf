resource "aws_iam_role" "bastion_role" {
  name = "cg-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_role_attachment" {
  role = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_instance_profile" "cg_bastion_instance_profile" {
  name = "cg_bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role" "cloud_trail_cloudwatch_role" {
  name = "cloudwatch_cloudtrail_role"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_policy" {
  name = "cloudtrail_cloudwatch_policy"
  path = "/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AWSCloudTrailCreateLogStream2014110",
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}:*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_policy_attachment" {
  role = aws_iam_role.cloud_trail_cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_policy.arn
}