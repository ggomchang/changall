variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type = string 
}

variable "route_table_name" {
  description = "Route Table Name tag"
  type        = string
}

variable "route_cidr_block" {
  description = "Route CIDR block"
  type        = string
}

variable "route_gateway_id" {
  description = "Route Gateway ID"
  type        = string
}