resource "aws_s3_bucket" "static_s3_bucket" {
  bucket = "changgom-1234-0403-zzang"

  force_destroy = true
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_s3_bucket.bucket_regional_domain_name
    origin_id = aws_s3_bucket.static_s3_bucket.id
  }

  enabled = true
  is_ipv6_enabled = false

  default_cache_behavior {
    viewer_protocol_policy = "allow-all"
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" #CachingOptimized
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # All Viewer
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_s3_bucket.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "apdev-cdn"
  }

  depends_on = [
    aws_s3_bucket.static_s3_bucket
  ]
}