resource "aws_iam_role" "bastion_role" {
  name = "seoul_2_3_bastion_role"

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
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "seoul_2_2_bastion_profile" {
  name = "seoul_2_3_bastion_profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_user" "tester_user" {
  name          = "tester"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "admin_user_policy" {
  user       = aws_iam_user.tester_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy" "mfa_access_s3_policy" {
  name = "mfaBucketDeleteControl"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Deny",
        "Action" : "s3:DeleteBucket",
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "aws:MultiFactorAuthPresent" : "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "mfa_user_policy" {
  user       = aws_iam_user.tester_user.name
  policy_arn = aws_iam_policy.mfa_access_s3_policy.arn
}

resource "aws_iam_group" "user_group" {
  name = "user_group_kr"
}

resource "aws_iam_user_group_membership" "tester_user_group_attach" {
  user = aws_iam_user.tester_user.name

  groups = [
    aws_iam_group.user_group.name
  ]
}

resource "aws_iam_policy" "region_access_policy" {
  name = "regionAccessControl"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Deny",
        "Action" : "*",
        "Resource" : "*",
        "Condition" : {
          "StringNotEquals" : {
            "aws:RequestedRegion" : "ap-northeast-2"
          }
        }
      }
    ]
  })
}


resource "aws_iam_group_policy_attachment" "user_group_policy_attach" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.region_access_policy.arn
}
