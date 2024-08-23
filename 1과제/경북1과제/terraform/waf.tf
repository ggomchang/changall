resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider = aws.virginia

  name  = "cloudfront_waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudfront_waf"
    sampled_requests_enabled   = false
  }

  custom_response_body {
    content_type = "TEXT_PLAIN"
    content = "Access Denied"
    key = "403"
  }

  rule {
    name     = "user-agent"
    priority = 1
    statement {
      not_statement {
        statement {
          byte_match_statement {
            search_string = "safe-client"
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }
    action {
      block {
        custom_response {
          response_code = 403
          custom_response_body_key = "403"
        }
      }
    }
    visibility_config {
      sampled_requests_enabled   = false
      cloudwatch_metrics_enabled = false
      metric_name                = "http"
    }
  }
}

resource "aws_wafv2_web_acl" "alb_waf" {
  name  = "alb_waf"
  scope = "REGIONAL"


  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "alb_waf"
    sampled_requests_enabled   = false
  }

  custom_response_body {
    content_type = "TEXT_PLAIN"
    content = "Access Denied"
    key = "403"
  }

  rule {
    name     = "custom-header"
    priority = 1
    statement {
      not_statement {
        statement {
          byte_match_statement {
            search_string = "Skills2024"
            field_to_match {
              single_header {
                name = "x-wsi-header"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "EXACTLY"
          }
        }
      }
    }
    action {
      block {
        custom_response {
          response_code = 403
          custom_response_body_key = "403"
        }
      }
    }
    visibility_config {
      sampled_requests_enabled   = false
      cloudwatch_metrics_enabled = false
      metric_name                = "http"
    }
  }
}