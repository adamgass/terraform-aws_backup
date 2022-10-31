terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "vpc-tf-backend-363638675288"
    key            = "backup-tf.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-table"
  }
}

