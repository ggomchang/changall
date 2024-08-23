resource "aws_s3_bucket" "static_s3_bucket" {
  bucket = "apne2-wsi-static-403"

  force_destroy = true

  tags = {
    Name = "wsc2024-s3-static-403"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  bucket = aws_s3_bucket.static_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.static_s3_bucket.id
  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
      {
          "Sid": "AllowCloudFrontServicePrincipal",
          "Effect": "Allow",
          "Principal": {
              "Service": "cloudfront.amazonaws.com"
          },
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.static_s3_bucket.arn}/*",
          "Condition": {
              "StringEquals": {
                  "AWS:SourceArn": "${aws_cloudfront_distribution.cdn.arn}"
              }
          }
      }
    ]
  })
}


resource "aws_s3_object" "s3_bucket_folder" {
  bucket = aws_s3_bucket.static_s3_bucket.id
  key    = "static/"
}