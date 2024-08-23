resource "aws_wafv2_web_acl" "alb_waf" {
  name  = "wsi-waf"
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
    content = "Blocked by WAF"
    key = "401"
  }

  rule {
    name     = "alg_none_block"
    priority = 1
    statement {
      and_statement {
        statement {
          byte_match_statement {
            search_string = "/v1/token/verify"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "EXACTLY"
          }
        }
        statement {
          byte_match_statement {
            search_string = "\"alg\": \"none\""
            field_to_match {
              single_header {
                name = "authorization"
              }
            }
            text_transformation {
              priority = 0
              type     = "BASE64_DECODE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }
    action {
      block {
        custom_response {
          response_code = 401
          custom_response_body_key = "401"
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

resource "aws_wafv2_web_acl_association" "alb_waf_association" {
  web_acl_arn = aws_wafv2_web_acl.alb_waf.arn
  resource_arn = aws_lb.wsi_alb.arn
}