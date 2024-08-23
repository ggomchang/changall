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

  ingress {
    protocol = "tcp"
    from_port = "3307"
    to_port = "3307"
    security_groups = [
      aws_security_group.app_sg.id
    ]
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

resource "aws_db_instance" "rds_instance" {
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.m5.xlarge"
  db_name = "wsi"
  identifier = "wsi-rds-mysql"
  username = "admin"
  manage_master_user_password = true
  port = 3307
  multi_az = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  storage_encrypted = true
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  allocated_storage = 400
  skip_final_snapshot = true

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery"
  ]

}