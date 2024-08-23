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

resource "aws_kms_key" "us_s3_cmk" {
  provider = aws.verginia
}

resource "aws_kms_alias" "us_s3_cmk_alias" {
  provider = aws.verginia
  name          = "alias/s3_cmk"
  target_key_id = aws_kms_key.us_s3_cmk.id
}

resource "aws_kms_key_policy" "us_s3_cmk_policy" {
  provider = aws.verginia
  key_id = aws_kms_key.us_s3_cmk.id
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

resource "aws_kms_key" "eks_cmk" {

}

resource "aws_kms_alias" "eks_cmk_alias" {
  name          = "alias/eks_cmk"
  target_key_id = aws_kms_key.eks_cmk.id
}
