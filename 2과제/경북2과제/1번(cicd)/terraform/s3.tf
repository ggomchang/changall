resource "aws_s3_bucket" "codepipeline_s3_bucket" {
  bucket = "codepipeline-s3-bucket-hyun-zzang-qweasdzxc"

  force_destroy = true
}

resource "aws_s3_bucket_policy" "codepipeline_s3_bucket_policy" {
  bucket = aws_s3_bucket.codepipeline_s3_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "SSEAndSSLPolicy",
    "Statement": [
      {
        "Sid": "DenyUnEncryptedObjectUploads",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.codepipeline_s3_bucket.arn}/*",
        "Condition": {
          "StringNotEquals": {
              "s3:x-amz-server-side-encryption": "aws:kms"
          }
        }
      },
      {
        "Sid": "DenyInsecureConnections",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": "${aws_s3_bucket.codepipeline_s3_bucket.arn}/*",
        "Condition": {
          "Bool": {
              "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}