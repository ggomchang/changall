variable "oac_name" {
  description = "The name of the origin access control"
  type        = string
  default     = "cloudfront-s3-oac"
}

variable "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  type        = string
}

variable "bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
}

variable "bucket" {
  description = "The S3 bucket"
  type        = any
}

variable "default_root_object" {
  description = "The default root object"
  type        = string
}

# variable "event_type" {
#   description = "The type of event that triggers the Lambda function"
#   type        = string
# }

# variable "lambda_arn" {
#   description = "The ARN of the Lambda function"
#   type        = string
# }

# variable "lambda_function_associations" {
#   description = ""
#   type = list(object({
#     event_type = string
#     lambda_arn = any
#   }))
# }

variable "resizing_lambda_arn" {
  description = "The ARN of the Lambda function for resizing images"
  type        = string
}
