resource "aws_s3_bucket" "ap_s3_bucket" {
  bucket = "ap-wsi-static-hyun"

  force_destroy = true
}

resource "aws_s3_bucket" "us_s3_bucket" {
  provider = aws.verginia

  bucket = "us-wsi-static-hyun"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "ap_s3_bucket_public" {
  bucket = aws_s3_bucket.ap_s3_bucket.id
}

resource "aws_s3_bucket_public_access_block" "us_s3_bucket_public" {
  provider = aws.verginia
  bucket = aws_s3_bucket.us_s3_bucket.id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ap_s3_bucket_encryption" {
  bucket = aws_s3_bucket.ap_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "us_s3_bucket_encryption" {
  provider = aws.verginia

  bucket = aws_s3_bucket.us_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.us_s3_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.ap_s3_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Sid" : "AllowCloudFrontServicePrincipalReadWrite",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "cloudfront.amazonaws.com"
      },
      "Action" : [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource" : "${aws_s3_bucket.ap_s3_bucket.arn}/*",
      "Condition" : {
        "StringEquals" : {
          "AWS:SourceArn" : "${aws_cloudfront_distribution.cdn.arn}"
        }
      }
    }
  })

  depends_on = [
    aws_cloudfront_distribution.cdn
  ]
}

resource "aws_s3_bucket_policy" "us_s3_bucket_policy" {
  provider = aws.verginia

  bucket = aws_s3_bucket.us_s3_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.us_s3_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cdn.arn}"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.cdn
  ]
}

resource "aws_s3_bucket_versioning" "ap_s3_bucket_versioning" {
  bucket = aws_s3_bucket.ap_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "us_s3_bucket_versioning" {
  provider = aws.verginia

  bucket = aws_s3_bucket.us_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "s3_replication_configuration" {
  bucket = aws_s3_bucket.ap_s3_bucket.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id = "s3replication"

    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = aws_s3_bucket.us_s3_bucket.arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.us_s3_cmk.arn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    delete_marker_replication {
      status = "Disabled"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.ap_s3_bucket_versioning,
    aws_s3_bucket_versioning.us_s3_bucket_versioning
  ]
}
