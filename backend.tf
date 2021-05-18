terraform {
  backend "s3" {
    bucket = "dev-terraform-backend"
    key    = "dev.tfstate"
    region = = var.aws_region
    encrypt = true
    dynamodb_table = "terraform-state-lock-dynamo"
    }
  }
