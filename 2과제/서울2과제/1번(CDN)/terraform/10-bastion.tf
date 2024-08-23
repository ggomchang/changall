module "bastion" {
  source = "./modules/ec2/instance"

  instance_name = "wsi-bastion"
  ami = "ami-0c2acfcb2ac4d02a0"
  instance_type = "t3.small"
  associate_public_ip_address = true

  subnet_id = module.subnet_a.subnet_id
  sg_id = module.bastion_sg.sg_id
  keypair_name = module.bastion_keypair.keypair_name
  instance_profile_name = module.bastion_instance_profile.name
}

module "bastion_instance_profile" {
  source = "./modules/iam/instance_profile"

  instance_profile_name = "wsi-bastion-instance-profile"
  role_name             = module.bastion_role.role_name
}


module "bastion_keypair" {
  source = "./modules/ec2/keypair"

  key_name = "wsi-key"
  key_filename = "bastion.pem"
}

module "bastion_sg" {
  source = "./modules/vpc/sg"

  vpc_id = module.vpc.vpc_id
  sg_name = "wsi-bastion-sg"
  ingress_cidr_ipv4 = "0.0.0.0/0"
  ingress_from_port = "22"
  ingress_ip_protocol = "tcp"
  ingress_to_port = "22"
}