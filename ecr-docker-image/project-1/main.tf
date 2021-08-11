provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-using-ecs-task"
  acl    = "private"
}