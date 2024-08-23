resource "aws_s3_bucket" "s3_original_bucket" {
  bucket = "j-s3-bucket-changzz-original"

  force_destroy = true
}

resource "aws_s3_bucket" "s3_backup_bucket" {
  bucket = "j-s3-bucket-changzz-backup"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "s3_backup_original_versioning" {
  bucket = aws_s3_bucket.s3_original_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "s3_backup_bucket_versioning" {
  bucket = aws_s3_bucket.s3_backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_original_bucket_public" {
  bucket = aws_s3_bucket.s3_original_bucket.id
}

resource "aws_s3_bucket_public_access_block" "s3_backup_bucket_public" {
  bucket = aws_s3_bucket.s3_backup_bucket.id
}

resource "aws_s3_bucket_policy" "s3_original_bucket_policy" {
  bucket = aws_s3_bucket.s3_original_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1721629661328",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "${aws_s3_bucket.s3_original_bucket.arn}/*",
        "Principal": "*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.s3_original_bucket_public
  ]
}

resource "aws_s3_bucket_policy" "s3_backup_bucket_policy" {
  bucket = aws_s3_bucket.s3_backup_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DenyDirectUploadTo2024Folder",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.s3_backup_bucket.arn}/2024/*"
        "Condition": {
          "StringNotEquals": {
              "s3:x-amz-metadata-directive": "COPY"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.s3_backup_bucket_public
  ]
}


resource "aws_s3_bucket_replication_configuration" "s3_replication_configuration" {
  bucket = aws_s3_bucket.s3_original_bucket.id
  role = aws_iam_role.s3_replication_role.arn

  rule {
    id = "s3replication"

    filter {
      prefix = "2024"
    }

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.s3_backup_bucket.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Disabled"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.s3_backup_original_versioning
  ]
}

resource "aws_s3_bucket_notification" "backup_bucket_notification" {
  
  bucket = aws_s3_bucket.s3_backup_bucket.id

  queue {
    queue_arn = aws_sqs_queue.sqs.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "2024/"
  }
}