resource "aws_vpc" "prod_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wsc2024-prod-vpc"
  }
}

resource "aws_subnet" "prod_load_subnet_a" {
  vpc_id = aws_vpc.prod_vpc.id

  cidr_block = "172.16.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc2024-prod-load-sn-a"
  }
}

resource "aws_subnet" "prod_load_subnet_b" {
  vpc_id = aws_vpc.prod_vpc.id

  cidr_block = "172.16.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc2024-prod-load-sn-b"
  }
}

resource "aws_subnet" "prod_app_subnet_a" {
  vpc_id = aws_vpc.prod_vpc.id

  cidr_block = "172.16.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "wsc2024-prod-app-sn-a"
  }
}

resource "aws_subnet" "prod_app_subnet_b" {
  vpc_id = aws_vpc.prod_vpc.id

  cidr_block = "172.16.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "wsc2024-prod-app-sn-b"
  }
}

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "wsc2024-prod-igw"
  }
}

resource "aws_route_table" "prod_load_rt" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "wsc2024-prod-load-rt"
  }
}

resource "aws_route_table_association" "prod_load_rt_association_a" {
  subnet_id      = aws_subnet.prod_load_subnet_a.id
  route_table_id = aws_route_table.prod_load_rt.id
}

resource "aws_route_table_association" "prod_load_rt_association_b" {
  subnet_id      = aws_subnet.prod_load_subnet_b.id
  route_table_id = aws_route_table.prod_load_rt.id
}

resource "aws_route" "prod_load_rt_route" {
  route_table_id = aws_route_table.prod_load_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.prod_igw.id
}

resource "aws_eip" "prod_nat_a_eip" {
  domain = "vpc"
}


resource "aws_eip" "prod_nat_b_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "prod_nat_a" {
  allocation_id = aws_eip.prod_nat_a_eip.id

  subnet_id = aws_subnet.prod_load_subnet_a.id

  tags = {
    Name = "wsc2024-prod-natgw-a"
  }
}

resource "aws_nat_gateway" "prod_nat_b" {
  allocation_id = aws_eip.prod_nat_b_eip.id

  subnet_id = aws_subnet.prod_load_subnet_b.id

  tags = {
    Name = "wsc2024-prod-natgw-b"
  }
}

resource "aws_route_table" "prod_app_rt_a" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = {
    Name = "wsc2024-prod-app-rt-a"
  }
}

resource "aws_route_table" "prod_app_rt_b" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "wsc2024-prod-app-rt-b"
  }
}

resource "aws_route_table_association" "prod_app_rt_a_association" {
  subnet_id      = aws_subnet.prod_app_subnet_a.id
  route_table_id = aws_route_table.prod_app_rt_a.id
}

resource "aws_route_table_association" "prod_app_rt_b_association" {
  subnet_id      = aws_subnet.prod_app_subnet_b.id
  route_table_id = aws_route_table.prod_app_rt_b.id
}

resource "aws_route" "prod_app_rt_a_route" {
  route_table_id              = aws_route_table.prod_app_rt_a.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.prod_nat_a.id
}

resource "aws_route" "prod_app_rt_b_route" {
  route_table_id              = aws_route_table.prod_app_rt_b.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.prod_nat_b.id
}

resource "aws_security_group" "prod_endpoint_sg" {
  name        = "prod-endpoint-sg"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "prod-endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "prod_ecr_dkr_endpoint" {
  vpc_id = aws_vpc.prod_vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.prod_app_subnet_a.id,
    aws_subnet.prod_app_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.prod_endpoint_sg.id
  ]

  tags = {
    Name = "prod-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "prod_s3_endpoint" {
  vpc_id = aws_vpc.prod_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ 
    aws_route_table.prod_app_rt_a.id,
    aws_route_table.prod_app_rt_b.id
  ]

  tags = {
    Name = "prod-s3-endpoint"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "alb-sg"
  }
}