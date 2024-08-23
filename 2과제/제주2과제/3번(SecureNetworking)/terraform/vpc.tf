resource "aws_vpc" "vpc" {
  cidr_block = "210.89.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "J-VPC"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "210.89.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "J-company-priv-sub-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "210.89.2.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "J-company-priv-sub-b"
  }
}

resource "aws_route_table" "rtb_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "J-company-priv-rt-a"
  } 
}

resource "aws_route_table" "rtb_b" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "J-company-priv-rt-b"
  } 
}

resource "aws_route_table_association" "rtb_association_a" {
  route_table_id = aws_route_table.rtb_a.id
  subnet_id = aws_subnet.subnet_a.id
}

resource "aws_route_table_association" "rtb_association_b" {
  route_table_id = aws_route_table.rtb_b.id
  subnet_id = aws_subnet.subnet_b.id
}

resource "aws_security_group" "J_company_endpoint_sg" {
  name = "J_company_endpoint_sg"
  vpc_id = aws_vpc.vpc.id

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
    Name = "J_company_endpoint_sg"
  }
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect_endpoint" {
  subnet_id = aws_subnet.subnet_b.id

  security_group_ids = [
    aws_security_group.J_company_endpoint_sg.id
  ]

  tags = {
    Name = "j-company-endpoint-ec2"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ 
    aws_route_table.rtb_a.id,
    aws_route_table.rtb_b.id
  ]

  tags = {
    Name = "j-company-endpoint-s3"
  }
}

resource "aws_vpc_endpoint" "sqs_endpoint" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.sqs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]

  security_group_ids = [
    aws_security_group.J_company_endpoint_sg.id
  ]

  tags = {
    Name = "j-company-endpoint-sqs"
  }
}