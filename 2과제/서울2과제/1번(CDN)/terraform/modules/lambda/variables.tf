variable "function_name" {
  description = "The name of the Lambda function"
  type = string
}

variable "runtime" {
  description = "The runtime to use for the Lambda function"
  type = string
}

variable "filename" {
  description = "The filename of the Lambda function"
  type = string
}

variable "role_arn" {
  description = "The ARN of the IAM role to use for the Lambda function"
  type = string
}

variable "handler" {
  description = "The handler to use for the Lambda function"
  type = string
}