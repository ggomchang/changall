variable "bucket_name" {
  description = "The name of the S3 bucket"
  type = string
}

variable "bucket_policy" {
  description = "The policy to apply to the S3 bucket"
  type = any
}