resource "aws_default_vpc" "default_vpc" {
  force_destroy = true

  tags = {
    Name = "default_vpc"
  }
}