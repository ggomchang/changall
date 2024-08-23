resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support = "enable"
  vpn_ecmp_support = "enable"
  amazon_side_asn = 65000

  tags = {
    Name = "wsc2024-vpc-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ma_vpc_tgw_attachment" {
  vpc_id = aws_vpc.ma_vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.ma_subnet_a.id,
    aws_subnet.ma_subnet_b.id
  ]

  tags = {
    Name = "wsc2024-ma-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_vpc_tgw_attachment" {
  vpc_id = aws_vpc.prod_vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.prod_app_subnet_a.id,
    aws_subnet.prod_app_subnet_b.id
  ]

  tags = {
    Name = "wsc2024-prod-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "storage_vpc_tgw_attachment" {
  vpc_id = aws_vpc.storage_vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = [
    aws_subnet.storage_subnet_a.id,
    aws_subnet.storage_subnet_b.id
  ]

  tags = {
    Name = "wsc2024-storage-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "ma_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "wsc2024-ma-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "prod_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "wsc2024-prod-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "storage_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "wsc2024-storage-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "ma_tgw_assciation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ma_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ma_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "prod_tgw_assciation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "storage_tgw_assciation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.storage_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.storage_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "ma_tgw_rt_prod_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ma_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "ma_tgw_rt_storage_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.storage_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ma_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_tgw_rt_ma_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ma_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_tgw_rt_storage_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.storage_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "storage_tgw_rt_ma_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ma_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.storage_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "storage_tgw_rt_prod_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.storage_tgw_rt.id
}

resource "aws_route" "ma_rt_route_prod_tgw" {
  route_table_id            = aws_route_table.ma_mgmt_rt.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "ma_rt_route_storage_tgw" {
  route_table_id            = aws_route_table.ma_mgmt_rt.id
  destination_cidr_block    = "192.168.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prod_app_rt_a_route_ma_tgw" {
  route_table_id            = aws_route_table.prod_app_rt_a.id
  destination_cidr_block    = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prod_app_rt_a_route_storage_tgw" {
  route_table_id            = aws_route_table.prod_app_rt_a.id
  destination_cidr_block    = "192.168.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prod_app_rt_b_route_ma_tgw" {
  route_table_id            = aws_route_table.prod_app_rt_b.id
  destination_cidr_block    = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "prod_app_rt_b_route_storage_tgw" {
  route_table_id            = aws_route_table.prod_app_rt_b.id
  destination_cidr_block    = "192.168.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "storage_rt_a_route_ma_tgw" {
  route_table_id            = aws_route_table.storage_rt_a.id
  destination_cidr_block    = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "storage_rt_a_route_prod_tgw" {
  route_table_id            = aws_route_table.storage_rt_a.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "storage_rt_b_route_ma_tgw" {
  route_table_id            = aws_route_table.storage_rt_b.id
  destination_cidr_block    = "10.0.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "storage_rt_b_route_prod_tgw" {
  route_table_id            = aws_route_table.storage_rt_b.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}