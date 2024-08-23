variable "role_name" {
  description = "Role Name"
  type        = string
}

variable "role_policy" {
  description = "Role Policy"
  type        = any
}

variable "policy_arn" {
  description = "Policy ARN"
  type = string
}