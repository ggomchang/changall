resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "daejeon-eks-logging-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "daejeon-eks-logging-public-sn-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "daejeon-eks-logging-public-sn-b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "daejeon-eks-logging-private-sn-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "daejeon-eks-logging-private-sn-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "daejeon-eks-logging-igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "daejeon-eks-logging-public-rtb"
  } 
}

resource "aws_route_table_association" "rtb_association_a" {
  route_table_id = aws_route_table.rtb.id
  subnet_id = aws_subnet.public_subnet_a.id
}

resource "aws_route_table_association" "rtb_association_b" {
  route_table_id = aws_route_table.rtb.id
  subnet_id = aws_subnet.public_subnet_b.id
}

resource "aws_route" "rtb_route" {
  route_table_id = aws_route_table.rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "daejeon-eks-logging-private-rt"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.public_subnet_a.id

  tags = {
    Name = "daejeon-eks-logging-natgw-a"
  }
}

resource "aws_route_table_association" "app_a_rt_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "app_b_rt_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "app_a_rt_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}