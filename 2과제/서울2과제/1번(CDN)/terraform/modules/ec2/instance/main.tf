resource "aws_instance" "instance" {
  ami = var.ami // AWS Linux 2023
  instance_type = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = var.subnet_id
  key_name = var.keypair_name
  iam_instance_profile = var.instance_profile_name

  vpc_security_group_ids = [ var.sg_id ]

  tags = {
    Name = var.instance_name
  }
}