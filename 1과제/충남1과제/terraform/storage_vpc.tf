resource "aws_vpc" "storage_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "wsc2024-storage-vpc"
  }
}

resource "aws_subnet" "storage_subnet_a" {
  vpc_id = aws_vpc.storage_vpc.id

  cidr_block = "192.168.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "wsc2024-storage-db-sn-a"
  }
}

resource "aws_subnet" "storage_subnet_b" {
  vpc_id = aws_vpc.storage_vpc.id

  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "wsc2024-storage-db-sn-b"
  }
}

resource "aws_route_table" "storage_rt_a" {
  vpc_id = aws_vpc.storage_vpc.id

  tags = {
    Name = "wsc2024-storage-db-rt-a"
  }
}

resource "aws_route_table" "storage_rt_b" {
  vpc_id = aws_vpc.storage_vpc.id

  tags = {
    Name = "wsc2024-storage-db-rt-b"
  }
}

resource "aws_route_table_association" "storage_rt_a_association" {
  subnet_id      = aws_subnet.storage_subnet_a.id
  route_table_id = aws_route_table.storage_rt_a.id
}

resource "aws_route_table_association" "storage_rt_b_association" {
  subnet_id      = aws_subnet.storage_subnet_b.id
  route_table_id = aws_route_table.storage_rt_b.id
}