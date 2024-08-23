resource "aws_secretsmanager_secret" "customer_secretsmanager" {
  name = "customer"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "customer_secret_version" {
  secret_id = aws_secretsmanager_secret.customer_secretsmanager.id
  secret_string = jsonencode({
    "MYSQL_USER" : "${aws_rds_cluster.rds_cluster.master_username}"
    "MYSQL_PASSWORD" : "${aws_rds_cluster.rds_cluster.master_password}"
    "MYSQL_HOST" : "${aws_rds_cluster.rds_cluster.endpoint}"
    "MYSQL_PORT" : "${aws_rds_cluster.rds_cluster.port}"
    "MYSQL_DBNAME" : "customer"
  })
  version_stages = ["AWSCURRENT"]

  depends_on = [
    aws_rds_cluster.rds_cluster,
  ]
}

resource "aws_secretsmanager_secret" "product_secretsmanager" {
  name = "product"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "product_secret_version" {
  secret_id = aws_secretsmanager_secret.product_secretsmanager.id
  secret_string = jsonencode({
    "MYSQL_USER" : "${aws_rds_cluster.rds_cluster.master_username}"
    "MYSQL_PASSWORD" : "${aws_rds_cluster.rds_cluster.master_password}"
    "MYSQL_HOST" : "${aws_rds_cluster.rds_cluster.endpoint}"
    "MYSQL_PORT" : "${aws_rds_cluster.rds_cluster.port}"
    "MYSQL_DBNAME" : "product"
  })
  version_stages = ["AWSCURRENT"]

  depends_on = [
    aws_rds_cluster.rds_cluster
  ]
}

resource "aws_secretsmanager_secret" "order_secretsmanager" {
  name = "order"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "order_secret_version" {
  secret_id = aws_secretsmanager_secret.order_secretsmanager.id
  secret_string = jsonencode({
    "AWS_REGION" : "ap-northeast-2"
  })
  version_stages = ["AWSCURRENT"]
}