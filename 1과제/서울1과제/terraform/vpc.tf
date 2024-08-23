resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wsi-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-public-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.3.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-public-b"
  }
}

resource "aws_subnet" "app_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-app-a"
  }
}

resource "aws_subnet" "app_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "wsi-app-b"
  }
}

resource "aws_subnet" "data_subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "wsi-data-a"
  }
}

resource "aws_subnet" "data_subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.1.5.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "wsi-data-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route" "public_rt_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
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
    Name = "wsi-natgw-a"
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b_eip.id

  subnet_id = aws_subnet.public_subnet_b.id

  tags = {
    Name = "wsi-natgw-b"
  }
}

resource "aws_route_table" "app_rt_a" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "wsi-app-a-rt"
  }
}

resource "aws_route_table" "app_rt_b" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-app-b-rt"
  }
}

resource "aws_route_table_association" "app_rt_a_association" {
  subnet_id      = aws_subnet.app_subnet_a.id
  route_table_id = aws_route_table.app_rt_a.id
}

resource "aws_route_table_association" "app_rt_b_association" {
  subnet_id      = aws_subnet.app_subnet_b.id
  route_table_id = aws_route_table.app_rt_b.id
}

resource "aws_route" "app_rt_a_route" {
  route_table_id              = aws_route_table.app_rt_a.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_a.id
}

resource "aws_route" "app_rt_b_route" {
  route_table_id              = aws_route_table.app_rt_b.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_b.id
}

resource "aws_route_table" "data_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "wsi-data-rt"
  }
}

resource "aws_route_table_association" "data_rt_association_a" {
  subnet_id      = aws_subnet.data_subnet_a.id
  route_table_id = aws_route_table.data_rt.id
}

resource "aws_route_table_association" "data_rt_association_b" {
  subnet_id      = aws_subnet.data_subnet_b.id
  route_table_id = aws_route_table.data_rt.id
}

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint-sg"
  vpc_id      = aws_vpc.vpc.id

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
    Name = "endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ 
    aws_route_table.app_rt_a.id,
    aws_route_table.app_rt_b.id
  ]

  tags = {
    Name = "s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ 
    aws_route_table.app_rt_a.id,
    aws_route_table.app_rt_b.id
  ]

  tags = {
    Name = "dynamodb-endpoint"
  }
}

resource "aws_flow_log" "ma_vpc_flog_log" {
  iam_role_arn = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.vpc.id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
 name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol = "-1"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
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

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  vpc_id      = aws_vpc.vpc.id

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
    Name = "app-sg"
  }
}