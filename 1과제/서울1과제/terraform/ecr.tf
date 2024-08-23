resource "aws_ecr_repository" "customer_repo" {
  name = "customer"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "product_repo" {
  name = "product"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "order_repo" {
  name = "order"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "ecr_replication" {
  replication_configuration {
    rule {
      destination {
        region = "us-east-1"
        registry_id = data.aws_caller_identity.current.account_id
      }

      repository_filter {
        filter = "customer"
        filter_type = "PREFIX_MATCH"
      }

      repository_filter {
        filter = "product"
        filter_type = "PREFIX_MATCH"
      }

      repository_filter {
        filter = "order"
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}