variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "sg_name" {
  description = "Security Group Name tag"
  type        = string
}

variable "ingress_cidr_ipv4" {
  description = "Ingress CIDR IPv4"
  type        = string
}

variable "ingress_from_port" {
  description = "Ingress from port"
  type        = number
}

variable "ingress_ip_protocol" {
  description = "IP Protocol"
  type        = string
  default = "tcp"
}

variable "ingress_to_port" {
  description = "To Port"
  type        = number
}