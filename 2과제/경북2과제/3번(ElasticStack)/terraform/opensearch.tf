resource "aws_opensearch_domain" "opensearch" {
  domain_name    = "wsi-opensearch"
  engine_version = "OpenSearch_2.13"

  cluster_config {
    instance_count           = 2
    instance_type            = "t3.medium.search"
    dedicated_master_enabled = true
    dedicated_master_type    = "t3.medium.search"
    dedicated_master_count   = 3

    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  ebs_options {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_type = "gp3"
    volume_size = 20
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = "Password01!"
    }
  }
}

resource "aws_opensearch_domain_policy" "opensearch_policy" {
  domain_name = aws_opensearch_domain.opensearch.domain_name
  access_policies = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "es:*",
        "Resource" : "${aws_opensearch_domain.opensearch.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_opensearch_domain.opensearch
  ]
}