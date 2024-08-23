variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = "bastion-key"
}

variable "key_filename" {
  description = "The filename of the key pair"
  type        = string
  default     = "bastion-key.pem"
}