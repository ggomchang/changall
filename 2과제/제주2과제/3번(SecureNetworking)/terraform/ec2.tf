resource "aws_security_group" "bastion_sg" {
  name = "J-company-bastion-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "J-company-bastion-sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-04ea5b2d3c8ceccf8"
  instance_type = "t3.small"
  subnet_id = aws_subnet.subnet_b.id
  iam_instance_profile = aws_iam_instance_profile.J_company_bastion_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "J-company-bastion"
  }
}