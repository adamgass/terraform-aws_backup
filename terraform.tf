terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # set backend s3 configureation by adding the bucket name, region, and dynamo db table for locking
  backend "s3" {
    bucket         = "<backend s3 bucket name>"
    key            = "backup-tf.tfstate"
    region         = "<AWS region>"
    dynamodb_table = "<dynamo db table name>"
  }
}

