resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private-a"
    "karpenter.sh/discovery" = "apdev-eks-cluster"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "private-b"
    "karpenter.sh/discovery" = "apdev-eks-cluster"
  }
}

resource "aws_subnet" "data_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "data-a"
  }
}

resource "aws_subnet" "data_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "data-b"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public-rtb"
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

resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private-rtb-a"
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private-rtb-b"
  }
}

resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_eip_a.id

  subnet_id = aws_subnet.public_subnet_a.id

  tags = {
    Name = "natgw-a"
  }
}

resource "aws_eip" "nat_eip_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_eip_b.id

  subnet_id = aws_subnet.public_subnet_b.id

  tags = {
    Name = "natgw-b"
  }
}

resource "aws_route_table_association" "private_rt_a_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_rt_b_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

resource "aws_route" "private_rt_a_route" {
  route_table_id         = aws_route_table.private_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_rt_b_route" {
  route_table_id         = aws_route_table.private_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

resource "aws_route_table" "data_rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "data_rtb"
  }
}

resource "aws_route_table_association" "data_rt_association_a" {
  subnet_id      = aws_subnet.data_subnet_a.id
  route_table_id = aws_route_table.data_rtb.id
}


resource "aws_route_table_association" "data_rt_association_b" {
  subnet_id      = aws_subnet.data_subnet_b.id
  route_table_id = aws_route_table.data_rtb.id
}


resource "aws_security_group" "app_sg" {
  name = "app-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "8080"
    to_port = "8080"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "app-sg"
    "karpenter.sh/discovery": "apdev-eks-cluster"
  }
}