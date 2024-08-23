##### Keypair ##################################################################
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name = "wsi-keypair-busan2-cicd"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content = tls_private_key.rsa.private_key_pem
  filename = "bastion.pem"
}



##### Bastion Instance #########################################################
### EIP
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  associate_with_private_ip = aws_instance.bastion.private_ip
}

### SG
resource "aws_security_group" "bastion" {
  name = "wsi-bastion-SG"
  vpc_id = aws_default_vpc.default_vpc.id
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
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

### IAM Role
resource "aws_iam_role" "bastion" {
  name = "wsi-role-bastion-busan2-cicd"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "wsi-profile-bastion-busan2-cicd"
  role = aws_iam_role.bastion.name
}

### Launch Instance
resource "aws_instance" "bastion" {
  instance_type = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name
  ami = "ami-00ff737803101edd1"
  tags = {
    Name = "wsi-bastion"
  }
  user_data = file("./userdata.sh")
}




##### Server Instance ##########################################################
### EIP
resource "aws_eip" "server" {
  instance = aws_instance.server.id
  associate_with_private_ip = aws_instance.server.private_ip
}

### SG
resource "aws_security_group" "server" {
  name = "wsi-server-SG"
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
  }
  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }
  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

### Launch Instance
resource "aws_instance" "server" {
  instance_type = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.server.id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name
  ami = "ami-00ff737803101edd1"
  tags = {
    Name = "wsi-server"
  }
  user_data = file("userdata_server.sh")
}