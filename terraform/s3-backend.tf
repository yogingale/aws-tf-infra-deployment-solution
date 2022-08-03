resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-provisioning-backend"

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
    bucket = "tf-provisioning-backend"
    key    = "main-project"
    region = "us-east-1"
  }
}