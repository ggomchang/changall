resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.storage_subnet_a.id,
    aws_subnet.storage_subnet_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = aws_vpc.storage_vpc.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "3306"
    to_port = "3306"
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
  cluster_identifier = "wsc2024-db-cluster"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"
  master_username = "admin"
  master_password = "Skill53##"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  backtrack_window = 14400
  skip_final_snapshot = true
  database_name = "wsc2024_db"

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
  
  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
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
  identifier = "wsc2024-db-instance-${count.index}"
  engine = "aurora-mysql"
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
}