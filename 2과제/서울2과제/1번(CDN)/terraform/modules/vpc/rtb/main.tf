resource "aws_route_table" "rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.route_cidr_block
    gateway_id = var.route_gateway_id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "rtb_association" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.rtb.id
}