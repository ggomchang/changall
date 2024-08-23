module "resize_policy" {
  source = "./modules/iam/policy"

  policy_name = "wsi-resize-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:GetFunction",
          "lambda:EnableReplication",
          "iam:CreateServiceLinkedRole",
          "cloudfront:UpdateDistribution",
          "s3:GetObject",
          "kms:Decrypt"
        ],
        "Resource" : "*"
      }
    ]
  })
  role_name = module.resize_role.role_name
}

module "resize_role" {
  source = "./modules/iam/role"

  role_name = "wsi-resize-role"
  role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "edgelambda.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  policy_arn = module.resize_policy.policy_arn
}

module "bastion_role" {
  source = "./modules/iam/role"

  role_name = "wsi-bastion-role"
  role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}