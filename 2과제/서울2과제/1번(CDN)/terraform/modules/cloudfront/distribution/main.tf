resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = var.oac_name
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = var.bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = false

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    # cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" #CachingOptimized
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #CachingDisabled
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_id

    # forwarded_values {
    #   query_string = true
    #   cookies {
    #     forward = "none"
    #   }
    # }

    # dynamic "lambda_function_association" {
    #   for_each = var.lambda_function_associations
    #   content {
    #     event_type   = lambda_function_association.value.event_type
    #     lambda_arn   = lambda_function_association.value.lambda_arn
    #   }
    # }

    function_association {
      event_type = "viewer-request"
      function_arn = aws_cloudfront_function.go_index.arn
    }
  }

  ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    path_pattern = "/images*"
    
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_id
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    } 

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = var.resizing_lambda_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    var.bucket,
    var.resizing_lambda_arn
  ]
}

resource "aws_cloudfront_function" "go_index" {
  name = "go_index"
  runtime = "cloudfront-js-2.0"
  code = file("modules/go_index.js")
}