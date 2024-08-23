variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_name" {
  description = "Subnets Name tag"
  type        = string
}

variable "subnet_cidr_block" {
  description = "Subnets CIDR block"
  type        = string
}

variable "subnet_az" {
  description = "value of availability zone"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "value of subnet is public"
  type        = bool
}