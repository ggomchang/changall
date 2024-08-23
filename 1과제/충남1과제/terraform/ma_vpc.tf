resource "aws_vpc" "ma_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wsc2024-ma-vpc"
  }
}

resource "aws_subnet" "ma_subnet_a" {
  vpc_id = aws_vpc.ma_vpc.id

  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc2024-ma-mgmt-sn-a"
  }
}

resource "aws_subnet" "ma_subnet_b" {
  vpc_id = aws_vpc.ma_vpc.id

  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsc2024-ma-mgmt-sn-b"
  }
}

resource "aws_internet_gateway" "ma_igw" {
  vpc_id = aws_vpc.ma_vpc.id

  tags = {
    Name = "wsc2024-ma-igw"
  }
}

resource "aws_route_table" "ma_mgmt_rt" {
  vpc_id = aws_vpc.ma_vpc.id

  tags = {
    Name = "wsc2024-ma-mgmt-rt"
  }
}

resource "aws_route_table_association" "ma_mgmt_rt_acssociation_a" {
  route_table_id = aws_route_table.ma_mgmt_rt.id
  subnet_id = aws_subnet.ma_subnet_a.id
}

resource "aws_route_table_association" "ma_mgmt_rt_acssociation_b" {
  route_table_id = aws_route_table.ma_mgmt_rt.id
  subnet_id = aws_subnet.ma_subnet_b.id
}

resource "aws_route" "ma_mgmt_rt_route" {
  route_table_id = aws_route_table.ma_mgmt_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ma_igw.id
}

resource "aws_security_group" "ma_vpc_lattice_sg" {
  name        = "ma-vpc-lattice-sg"
  vpc_id      = aws_vpc.ma_vpc.id

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
    Name = "ma-vpc-lattice-sg"
  }
}

resource "aws_vpc_endpoint" "ma_s3_endpoint" {
  vpc_id = aws_vpc.ma_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.ma_mgmt_rt.id
  ]

  tags = {
    Name = "ma-s3-endpoint"
  }
}

resource "aws_vpc_endpoint_policy" "ma-ecr_pull_deny" {
  vpc_endpoint_id = aws_vpc_endpoint.ma_s3_endpoint.id
  policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "Deny-ecr-image",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*"
      },
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "*",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_flow_log" "ma_vpc_flog_log" {
  iam_role_arn = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.ma_vpc.id
}

resource "aws_vpclattice_service_network" "lattice_svc_net" {
  name = "wsc2024-lattice-svc-net"
  auth_type = "NONE"
}

resource "aws_vpclattice_service_network_vpc_association" "lattice_ma_vpc_association" {
  vpc_identifier = aws_vpc.ma_vpc.id
  service_network_identifier = aws_vpclattice_service_network.lattice_svc_net.id
  security_group_ids = [
    aws_security_group.ma_vpc_lattice_sg.id
  ]
}