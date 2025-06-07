terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# primary Queue setup

resource "aws_sqs_queue" "primary_dlq" {
    name = "primary_dlq_tfname"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}

resource "aws_sqs_queue" "primary_queue" {
    name = "primary_queue_tf"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
    

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.primary_dlq.arn
        maxReceiveCount     = 3
    })
  
}

resource "aws_sqs_queue_policy" "name" {
  queue_url = aws_sqs_queue.primary_queue.id 
  policy = jsonencode({
        "Version": "2012-10-17",
        "Id": "__default_policy_ID",
        "Statement": [
            {
                "Sid": "__owner_statement",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::442426858328:root"
                },
                "Action": "SQS:*",
                "Resource": aws_sqs_queue.primary_queue.arn 
            }
        ]
    })
}


# SNS
resource "aws_sns_topic" "notification_topic" {
  name = "notificationTopic_tf"
}



# iam roles and policy for lambda function (primary queue SQS->SNS)
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sqs_sns_policy" {
  name        = "lambda_sqs_sns_policy"
  description = "Allow Lambda to access SQS, SNS and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.primary_queue.arn 
      },
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = aws_sns_topic.notification_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attatch_lambda_policy" {
    role = aws_iam_role.lambda_exec_role.name
    policy_arn = aws_iam_policy.lambda_sqs_sns_policy.arn
}


# lambda function (primary queue sqs -> sns)
resource "aws_lambda_function" "sqs_to_sns_lambda" {
    function_name = "SQSMessageToSNS_tf"
    role = aws_iam_role.lambda_exec_role.arn
    runtime = "python3.11"
    architectures = [ "x86_64" ]
    handler       = "lambda_function.lambda_handler"
    filename = "./lambda_functions/SQSToSNS/lambda.zip"

    environment {
      variables = {
        SNS_TOPIC_ARN = aws_sns_topic.notification_topic.arn
      }
    }
}

# lambda trigger
resource "aws_lambda_event_source_mapping" "primarySQS_trigger" {
    function_name = aws_lambda_function.sqs_to_sns_lambda.arn
    event_source_arn = aws_sqs_queue.primary_queue.arn
    batch_size = 10
}