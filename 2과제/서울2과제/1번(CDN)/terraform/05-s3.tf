module "bucket" {
  source = "./modules/s3"

  bucket_name = "wsi-static-chir"
  bucket_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Statement1",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::wsi-static-chir/*"
      }
    ]
  })
}