resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "gm_bastion"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "bastion.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_security_group" "bastion_sg" {
  name = "gm-bastion-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
  }

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "5000"
    to_port = "5000"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "gm-bastion-sg"
  }
}

resource "aws_security_group" "bastion_scripts_sg" {
  name = "gm-scripts-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "gm-scripts-sg"
  }
}

resource "aws_instance" "bastion_ec2" {
  ami = "ami-07f15eb4844514508"
  instance_type = "t3.small"
  subnet_id = aws_subnet.private_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "gm-bastion"
  }

  user_data = file("./userdata.sh")
}

resource "aws_instance" "bastion_scripts_ec2" {
  ami = "ami-07f15eb4844514508"
  instance_type = "t3.small"
  subnet_id = aws_subnet.public_subnet_a.id
  iam_instance_profile = aws_iam_instance_profile.bastion_scripts_instance_profile.name
  key_name = aws_key_pair.bastion_key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.bastion_scripts_sg.id
  ]

  tags = {
    Name = "gm-scripts"
  }

  user_data = file("./userdata.sh")
}
