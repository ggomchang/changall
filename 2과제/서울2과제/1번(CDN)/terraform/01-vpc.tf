module "vpc" {
  source = "./modules/vpc/vpc"

  vpc_name = "wsi-vpc"
  vpc_cidr_block = "10.0.0.0/16"
}

module "subnet_a" {
  source = "./modules/vpc/subnet"

  vpc_id = module.vpc.vpc_id
  subnet_name = "wsi-public-subnet-a"
  subnet_cidr_block = "10.0.0.0/24"
  subnet_az = "ap-northeast-2a"
  map_public_ip_on_launch = true
}

module "igw" {
  source = "./modules/vpc/igw"

  vpc_id = module.vpc.vpc_id
  igw_name = "wsi-igw"
}

module "rtb" {
  source = "./modules/vpc/rtb"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.subnet_a.subnet_id
  route_table_name = "wsi-public-rtb"
  route_cidr_block = "0.0.0.0/0"
  route_gateway_id = module.igw.internet_gateway_id
}