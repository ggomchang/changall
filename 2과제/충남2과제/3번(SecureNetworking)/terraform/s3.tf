resource "aws_s3_bucket" "static_s3_bucket" {
  bucket = "gm-0403"

  force_destroy = true

  tags = {
    Name = "gm-0403"
  }
}

resource "aws_s3_bucket_public_access_block" "public_s3" {
  bucket = aws_s3_bucket.static_s3_bucket.id
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.static_s3_bucket.id
  policy = jsonencode({
    "Id" : "Policy1722928038648",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1722928036361",
        "Action" : "s3:*",
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.static_s3_bucket.arn}/*",
        "Principal" : "*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.public_s3
  ]
}
