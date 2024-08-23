resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wsi-project-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-project-pub-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-project-pub-b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-project-priv-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "wsi-project-priv-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-project-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-project-pub-rt"
  } 
}

resource "aws_route_table_association" "public_rtb_association_a" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id = aws_subnet.public_subnet_a.id
}

resource "aws_route_table_association" "public_rtb_association_b" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id = aws_subnet.public_subnet_b.id
}

resource "aws_route" "rtb_route" {
  route_table_id = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_rtb_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-project-priv-a-rt"
  } 
}

resource "aws_route_table" "private_rtb_b" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-project-priv-b-rt"
  } 
}

resource "aws_eip" "nat_a_eip" {
  domain = "vpc"
}

resource "aws_eip" "nat_b_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a_eip.id

  subnet_id = aws_subnet.public_subnet_a.id

  tags = {
    Name = "wsi-project-nat-a"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b_eip.id

  subnet_id = aws_subnet.public_subnet_b.id

  tags = {
    Name = "wsi-project-nat-b"
  }
}

resource "aws_route_table_association" "private_rtb_a_association" {
  route_table_id = aws_route_table.private_rtb_a.id
  subnet_id = aws_subnet.private_subnet_a.id
}

resource "aws_route_table_association" "private_rtb_b_association" {
  route_table_id = aws_route_table.private_rtb_b.id
  subnet_id = aws_subnet.private_subnet_b.id
}

resource "aws_route" "private_rtb_a_route" {
  route_table_id = aws_route_table.private_rtb_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_rtb_b_route" {
  route_table_id = aws_route_table.private_rtb_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_b.id
}