resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.data_subnet_a.id,
    aws_subnet.data_subnet_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "3307"
    to_port = "3307"
  }

  egress {
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = "0"
    to_port          = "0"
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "wsi-aurora-mysql"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  master_username = "admin"
  master_password = "Skill53##"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot = true
  storage_encrypted  = true
  port = 3307

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
  
  availability_zones = [
    "ap-northeast-2a",
    "ap-northeast-2b"
  ]

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error"
  ]

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "rds_instance" {
  count = 2
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class = "db.t3.medium"
  identifier = "wsi-aurora-mysql-${count.index}"
  engine = aws_rds_cluster.rds_cluster.engine
  engine_version = aws_rds_cluster.rds_cluster.engine_version
}