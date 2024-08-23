variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "i-bastion"
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
  default     = "ami-0c2acfcb2ac4d02a0"
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t3.small"
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "sg_id" {
  description = "The security group ID to associate with the instance"
  type        = string
}

variable "keypair_name" {
  description = "The name of the keypair to use for the instance"
  type        = string
  default = "bastion-key"
}

variable "instance_profile_name" {
  description = "The IAM instance profile to associate with the instance"
  type        = string
}