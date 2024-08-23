resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "bastion"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "bastion.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "bastion_sg" {
  name = "wsc2024-bastion-sg"
  vpc_id = aws_vpc.ma_vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "28282"
    to_port = "28282"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "wsc2024-bastion-sg"
  }
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "bastion_ec2_eip_association" {
  instance_id = aws_instance.bastion_ec2.id
  allocation_id = aws_eip.bastion_eip.id
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-01b799c439fd5516a"
  instance_type = "t3.small"
  subnet_id = aws_subnet.ma_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "wsc2024-bastion-ec2"
  }

  user_data = file("./userdata.sh")
}
