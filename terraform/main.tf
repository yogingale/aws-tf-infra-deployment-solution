provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


# SQS queue
resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-provisioning-queue"
}


# Lambda function role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "sqs-policies"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
            ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

# Lambda function
resource "aws_lambda_function" "lambda" {
  filename      = "lambda.zip"
  function_name = "trigger-ecs-task"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"

  source_code_hash = filebase64sha256("lambda.zip")

  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# Log group for lambda function
resource "aws_cloudwatch_log_group" "trigger-ecs-task" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 365
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda.arn
  batch_size       = 1
}


# ECR repository
resource "aws_ecr_repository" "tf_task" {
  name                 = "tf-task"
}