resource "aws_instance" "vpc1_ec2" {
  ami = "ami-0f7712b35774b7da2"
  instance_type = "t3.small"
  subnet_id = aws_subnet.vpc1_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.tgw_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.vpc1_instance_sg.id
  ]

  tags = {
    Name = "gwangju-VPC1-Instance"
  }
}

resource "aws_instance" "vpc2_ec2" {
  ami = "ami-0f7712b35774b7da2"
  instance_type = "t3.small"
  subnet_id = aws_subnet.vpc2_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.tgw_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.vpc2_instance_sg.id
  ]

  tags = {
    Name = "gwangju-VPC2-Instance"
  }
}


resource "aws_instance" "vpc3_ec2" {
  ami = "ami-0f7712b35774b7da2"
  instance_type = "t3.small"
  subnet_id = aws_subnet.vpc3_subnet_b.id
  iam_instance_profile = aws_iam_instance_profile.tgw_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.vpc3_instance_sg.id
  ]

  tags = {
    Name = "gwangju-EgressVPC-Instance"
  }
}