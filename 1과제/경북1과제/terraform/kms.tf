resource "aws_kms_key" "dynamodb_cmk" {

}

resource "aws_kms_alias" "dynamodb_cmk_alias" {
  name          = "alias/dynamodb_cmk"
  target_key_id = aws_kms_key.dynamodb_cmk.id
}

resource "aws_kms_key" "s3_cmk" {

}

resource "aws_kms_alias" "s3_cmk_alias" {
  name          = "alias/s3_cmk"
  target_key_id = aws_kms_key.s3_cmk.id
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key_policy" "s3_cmk_policy" {
  key_id = aws_kms_key.s3_cmk.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowCloudFrontServicePrincipalSSE-KMS",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "cloudfront.amazonaws.com"
          ]
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cdn.arn}"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.cdn
  ]
}

resource "aws_kms_key" "cloudwatch_cmk" {

}

resource "aws_kms_alias" "cloudwatch_cmk_alias" {
  name          = "alias/cloudwatch_cmk"
  target_key_id = aws_kms_key.cloudwatch_cmk.id
}

resource "aws_kms_key_policy" "cloudwatch_cmk_policy" {
  key_id = aws_kms_key.cloudwatch_cmk.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.ap-northeast-2.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*",
        "Condition" : {
          "ArnLike" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:ap-northeast-2:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}
