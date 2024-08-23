resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "serverless-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.100.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "serverless-public-sn-a"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "serverless-igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "serverless-public-rt"
  } 
}

resource "aws_route_table_association" "rtb_association_a" {
  route_table_id = aws_route_table.rtb.id
  subnet_id = aws_subnet.subnet_a.id
}

resource "aws_route" "rtb_route" {
  route_table_id = aws_route_table.rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}