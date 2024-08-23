resource "aws_vpc" "vpc2" {
  cidr_block = "10.0.1.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "gwangju-VPC2"
  }
}

resource "aws_subnet" "vpc2_subnet_a" {
  vpc_id = aws_vpc.vpc2.id

  cidr_block = "10.0.1.0/25"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "vpc2-subnet-a"
  }
}

resource "aws_subnet" "vpc2_subnet_b" {
  vpc_id = aws_vpc.vpc2.id

  cidr_block = "10.0.1.128/25"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "vpc2-subnet-b"
  }
}

resource "aws_route_table" "vpc2_rt" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "vpc2-rt"
  }
}

resource "aws_route_table_association" "vpc2_rt_acssociation_a" {
  route_table_id = aws_route_table.vpc2_rt.id
  subnet_id = aws_subnet.vpc2_subnet_a.id
}

resource "aws_route_table_association" "vpc2_rt_acssociation_b" {
  route_table_id = aws_route_table.vpc2_rt.id
  subnet_id = aws_subnet.vpc2_subnet_b.id
}

resource "aws_security_group" "vpc2_instance_sg" {
  name = "vpc2-instance-sg"
  vpc_id = aws_vpc.vpc2.id

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
    Name = "vpc2-instance-sg"
  }
}

resource "aws_security_group" "vpc2_endpoint_sg" {
  name = "vpc2-endpoint-sg"
  vpc_id = aws_vpc.vpc2.id

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
    Name = "vpc2-endpoint-sg"
  }
}

resource "aws_vpc_endpoint" "vpc2_ssm_endpoint" {
  vpc_id = aws_vpc.vpc2.id
  service_name = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc2_subnet_a.id,
    aws_subnet.vpc2_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc2_endpoint_sg.id
  ]

  tags = {
    Name = "vpc2-ssm"
  }
}

resource "aws_vpc_endpoint" "vpc2_ec2messages_endpoint" {
  vpc_id = aws_vpc.vpc2.id
  service_name = "com.amazonaws.ap-northeast-2.ec2messages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc2_subnet_a.id,
    aws_subnet.vpc2_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc2_endpoint_sg.id
  ]

  tags = {
    Name = "vpc2-ec2messages"
  }
}

resource "aws_vpc_endpoint" "vpc2_ssmmessages_endpoint" {
  vpc_id = aws_vpc.vpc2.id
  service_name = "com.amazonaws.ap-northeast-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.vpc2_subnet_a.id,
    aws_subnet.vpc2_subnet_b.id
  ]

  security_group_ids = [ 
    aws_security_group.vpc2_endpoint_sg.id
  ]

  tags = {
    Name = "vpc2-ssmmessages"
  }
}