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

resource "aws_db_parameter_group" "parameter_group" {
  name = "apdev-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "max_connections"
    value = "100"
  }
}

resource "aws_db_instance" "rds_instance" {
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"
  db_name = "dev"
  identifier = "apdev-rds-instance"
  username = "admin"
  password = "password"
  port = 3306
  multi_az = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  storage_encrypted = true
  skip_final_snapshot = true
  storage_type = "gp3"
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  allocated_storage = 400
  iops = 64000
  storage_throughput = 1000

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