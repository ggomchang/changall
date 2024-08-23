resource "aws_s3_bucket" "static_s3_bucket" {
  bucket = "wsc2024-s3-static-hyun"

  force_destroy = true

  tags = {
    Name = "wsc2024-s3-static-hyun"
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