resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "es_bastion"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "bastion.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "bastion_sg" {
  name = "es-wsi-bastion-sg"
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
    Name = "wsi-bastion-sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-04ea5b2d3c8ceccf8"
  instance_type = "t3.small"
  subnet_id = aws_subnet.subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.es_bastion_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "wsi-bastion"
  }
}

resource "aws_security_group" "app_ec2_sg" {
  name = "wsi-app-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }

  tags = {
    Name = "wsi-app-sg"
  }
}

resource "aws_instance" "app_ec2" {
  ami = "ami-04ea5b2d3c8ceccf8"
  instance_type = "t3.small"
  subnet_id = aws_subnet.subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.es_bastion_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.app_ec2_sg.id
  ]

  tags = {
    Name = "wsi-app"
  }

  user_data = file("./userdata.sh")
}