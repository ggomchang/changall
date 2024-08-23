resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "cloudfront_s3_oac"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.ap_s3_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.ap_s3_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  origin {
    domain_name              = aws_s3_bucket.us_s3_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.us_s3_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  origin_group {
    origin_id = "s3group"

    member {
      origin_id = aws_s3_bucket.ap_s3_bucket.id
    }

    member {
      origin_id = aws_s3_bucket.us_s3_bucket.id
    }

    failover_criteria {
      status_codes = ["403"]
    }
  }

  custom_error_response {
    error_code = 403
    response_code = 503
    response_page_path = "/error.html"
  }

  enabled         = true
  is_ipv6_enabled = false

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" #CachingOptimized
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3group"
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
    Name = "wsi-cdn"
  }

  depends_on = [
    aws_s3_bucket.ap_s3_bucket,
    aws_s3_bucket.us_s3_bucket
  ]
}
