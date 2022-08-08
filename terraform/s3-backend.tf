resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_backend_bucket # Add this name in backend of child projects (Via SSM)

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    key    = "main-project/terraform.tfstate"
    region = "us-east-1"
  }
}