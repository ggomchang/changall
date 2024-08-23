resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "busan_2_2_bastion"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "bastion.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "bastion_sg" {
  name = "busan-2-2-bastion-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "2220"
    to_port = "2220"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "busan-2-2-bastion-sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-04ea5b2d3c8ceccf8"
  instance_type = "t3.small"
  subnet_id = aws_subnet.subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "wsi-bastion-ec2"
  }

  depends_on = [
    aws_iam_user.iam_user
  ]

  user_data = file("./userdata.sh")
}