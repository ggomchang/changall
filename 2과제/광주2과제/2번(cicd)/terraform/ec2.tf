resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "eks_cicd_bastion"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "bastion.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "bastion_sg" {
  name = "eks_cicd_bastion_sg"
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
    Name = "eks_cicd_bastion_sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-0f7712b35774b7da2"
  instance_type = "t3.small"
  subnet_id = aws_subnet.public_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.eks_cicd_bastion_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "eks_cicd_bastion"
  }

  user_data = file("./userdata.sh")
}