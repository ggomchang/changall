resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support = "enable"
  vpn_ecmp_support = "enable"
  amazon_side_asn = 65000

  tags = {
    Name = "tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_tgw_attachment" {
  vpc_id = aws_vpc.vpc1.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.vpc1_subnet_a.id,
    aws_subnet.vpc1_subnet_b.id
  ]

  tags = {
    Name = "vpc1-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_tgw_attachment" {
  vpc_id = aws_vpc.vpc2.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.vpc2_subnet_a.id,
    aws_subnet.vpc2_subnet_b.id
  ]

  tags = {
    Name = "vpc2-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3_tgw_attachment" {
  vpc_id = aws_vpc.vpc3.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.vpc3_subnet_a.id,
    aws_subnet.vpc3_subnet_b.id
  ]

  tags = {
    Name = "vpc3-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "vpc1_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "vpc1-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "vpc2_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "vpc2-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "vpc3_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "vpc3-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc1_tgw_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc2_tgw_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc2_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc3_tgw_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc1_tgw_vpc3_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc2_tgw_vpc3_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc2_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc3_tgw_vpc1_route" {
  destination_cidr_block         = "10.0.0.0/24"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "vpc3_tgw_vpc2_route" {
  destination_cidr_block         = "10.0.1.0/24"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_tgw_rt.id
}

resource "aws_route" "vpc1_rt_route_vpc3_tgw" {
  route_table_id            = aws_route_table.vpc1_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc3_rt_route_vpc1_tgw" {
  route_table_id            = aws_route_table.vpc3_rt.id
  destination_cidr_block    = "10.0.0.0/24"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc2_rt_route_vpc3_tgw" {
  route_table_id = aws_route_table.vpc2_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc3_public_rt_route_vpc1_tgw" {
  route_table_id         = aws_route_table.vpc3_public_rt.id
  destination_cidr_block = "10.0.0.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}