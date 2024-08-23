resource "aws_iam_role" "bastion_role" {
  name = "bastion-role"

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

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_user" "user1" {
  name          = "wsi-project-user1"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user" "user2" {
  name          = "wsi-project-user2"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "user1_read_only_policy_attachment" {
  user       = aws_iam_user.user1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_user_policy" "user1_ec2_create_policy" {
  name = "user1_ec2_create_policy"
  user = aws_iam_user.user1.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowRunInstancesWithRestrictions1",
        "Effect" : "Deny",
        "Action" : "ec2:RunInstances",
        "Resource": "arn:aws:ec2:*:*:instance/*",
        "Condition" : {
          "ForAllValues:StringNotEquals" : {
            "aws:TagKeys" : "wsi-project"
          }
        }
      },
      {
        "Sid" : "AllowRunInstancesWithRestrictions2",
        "Effect" : "Deny",
        "Action" : "ec2:RunInstances",
        "Resource" : "arn:aws:ec2:*:*:instance/*",
        "Condition" : {
          "StringNotEquals" : {
            "aws:RequestTag/wsi-project" : "developer"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeAddresses",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroupRules",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user2_read_only_policy_attachment" {
  user       = aws_iam_user.user2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_user_policy" "user2_ec2_delete_policy" {
  name = "user2_ec2_delete_policy"
  user = aws_iam_user.user2.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowRunInstancesWithRestrictions2",
        "Effect" : "Allow",
        "Action" : "ec2:TerminateInstances",
        "Resource" : "arn:aws:ec2:*:*:instance/*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/wsi-project" : "developer"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeAddresses",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroupRules",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress"
        ],
        "Resource" : "*"
      }
    ]
  })
}
