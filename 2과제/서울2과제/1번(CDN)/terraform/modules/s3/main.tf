resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [
    aws_s3_bucket_public_access_block.bucket_access
  ]

  policy = var.bucket_policy
}