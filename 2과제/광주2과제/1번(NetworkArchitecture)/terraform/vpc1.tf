resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "gwangju-VPC1"
  }
}

resource "aws_subnet" "vpc1_subnet_a" {
  vpc_id = aws_vpc.vpc1.id

  cidr_block = "10.0.0.0/25"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "vpc1-subnet-a"
  }
}

resource "aws_subnet" "vpc1_subnet_b" {
  vpc_id = aws_vpc.vpc1.id

  cidr_block = "10.0.0.128/25"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "vpc1-subnet-b"
  }
}

resource "aws_route_table" "vpc1_rt" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "vpc1-rt"
  }
}

resource "aws_route_table_association" "vpc1_rt_acssociation_a" {
  route_table_id = aws_route_table.vpc1_rt.id
  subnet_id = aws_subnet.vpc1_subnet_a.id
}

resource "aws_route_table_association" "vpc1_rt_acssociation_b" {
  route_table_id = aws_route_table.vpc1_rt.id
  subnet_id = aws_subnet.vpc1_subnet_b.id
}

resource "aws_security_group" "vpc1_instance_sg" {
  name = "vpc1-instance-sg"
  vpc_id = aws_vpc.vpc1.id

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
    Name = "vpc1-instance-sg"
  }
}

resource "aws_security_group" "vpc1_endpoint_sg" {
  name = "vpc1-endpoint-sg"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "vpc1-endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "vpc1_ssm_endpoint" {
  vpc_id = aws_vpc.vpc1.id
  service_name = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc1_subnet_a.id,
    aws_subnet.vpc1_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc1_endpoint_sg.id
  ]

  tags = {
    Name = "vpc1-ssm"
  }
}

resource "aws_vpc_endpoint" "vpc1_ssmmessages_endpoint" {
  vpc_id = aws_vpc.vpc1.id
  service_name = "com.amazonaws.ap-northeast-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc1_subnet_a.id,
    aws_subnet.vpc1_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc1_endpoint_sg.id
  ]

  tags = {
    Name = "vpc1-ssmmessages"
  }
}

resource "aws_vpc_endpoint" "vpc1_ec2messages_endpoint" {
  vpc_id = aws_vpc.vpc1.id
  service_name = "com.amazonaws.ap-northeast-2.ec2messages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc1_subnet_a.id,
    aws_subnet.vpc1_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc1_endpoint_sg.id
  ]

  tags = {
    Name = "vpc1-ec2messages"
  }
}