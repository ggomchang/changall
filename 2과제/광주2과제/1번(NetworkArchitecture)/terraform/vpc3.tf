resource "aws_vpc" "vpc3" {
  cidr_block = "10.0.2.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "gwangju-EgressVPC"
  }
}

resource "aws_subnet" "vpc3_public_subnet_a" {
  vpc_id = aws_vpc.vpc3.id

  cidr_block = "10.0.2.0/26"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc3-public-subnet-a"
  }
}

resource "aws_subnet" "vpc3_subnet_a" {
  vpc_id = aws_vpc.vpc3.id

  cidr_block = "10.0.2.64/26"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "vpc3-subnet-a"
  }
}

resource "aws_subnet" "vpc3_subnet_b" {
  vpc_id = aws_vpc.vpc3.id

  cidr_block = "10.0.2.128/26"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "vpc3-subnet-b"
  }
}

resource "aws_route_table" "vpc3_public_rt" {
  vpc_id = aws_vpc.vpc3.id

  tags = {
    Name = "vpc3-public-rt"
  }
}

resource "aws_route_table_association" "vpc3_public_rt_acssociation_a" {
  route_table_id = aws_route_table.vpc3_public_rt.id
  subnet_id = aws_subnet.vpc3_public_subnet_a.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc3.id

  tags = {
    Name = "vpc3-igw"
  }
}

resource "aws_route" "vpc3_public_rt_route" {
  route_table_id = aws_route_table.vpc3_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "vpc3_rt" {
  vpc_id = aws_vpc.vpc3.id

  tags = {
    Name = "vpc3-rt"
  }
}

resource "aws_route_table_association" "vpc3_rt_acssociation_a" {
  route_table_id = aws_route_table.vpc3_rt.id
  subnet_id = aws_subnet.vpc3_subnet_a.id
}

resource "aws_route_table_association" "vpc3_rt_acssociation_b" {
  route_table_id = aws_route_table.vpc3_rt.id
  subnet_id = aws_subnet.vpc3_subnet_b.id
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id

  subnet_id = aws_subnet.vpc3_public_subnet_a.id

  tags = {
    Name = "nat"
  }
}

resource "aws_route" "vpc3_rt_route" {
  route_table_id              = aws_route_table.vpc3_rt.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_gw.id
}

resource "aws_security_group" "vpc3_instance_sg" {
  name = "vpc3-instance-sg"
  vpc_id = aws_vpc.vpc3.id

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "vpc3-instance-sg"
  }
}