# primary queue policy
resource "aws_sqs_queue_policy" "PrimarySQSOwnerPolicy" {
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



# email sqs policy
resource "aws_sqs_queue_policy" "EmailSQSOwnerPolicy" {
  queue_url = aws_sqs_queue.email_queue.id 
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
                "Resource": aws_sqs_queue.email_queue.arn  
            },
            {
                "Sid": "allowSNSToSendToSQS",
                "Effect": "Allow",
                "Principal": {
                    "Service": "sns.amazonaws.com"
                },
                "Action": "SQS:SendMessage",
                "Resource": aws_sqs_queue.email_queue.arn ,
                "Condition": {
                    "ArnLike": {
                        "aws:SourceArn": aws_sns_topic.notification_topic.arn
                    }
                }
            }
        ]
    })
}


# whatsapp policy
resource "aws_sqs_queue_policy" "whatsappSQSOwnerPolicy" {
  queue_url = aws_sqs_queue.whatsapp_queue.id 
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
                "Resource": aws_sqs_queue.whatsapp_queue.arn  
            },
            {
                "Sid": "allowSNSToSendToSQS",
                "Effect": "Allow",
                "Principal": {
                    "Service": "sns.amazonaws.com"
                },
                "Action": "SQS:SendMessage",
                "Resource": aws_sqs_queue.whatsapp_queue.arn ,
                "Condition": {
                    "ArnLike": {
                        "aws:SourceArn": aws_sns_topic.notification_topic.arn
                    }
                }
            }
        ]
    })
}


# sms policy
resource "aws_sqs_queue_policy" "smsSQSOwnerPolicy" {
  queue_url = aws_sqs_queue.sms_queue.id 
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
                "Resource": aws_sqs_queue.sms_queue.arn  
            },
            {
                "Sid": "allowSNSToSendToSQS",
                "Effect": "Allow",
                "Principal": {
                    "Service": "sns.amazonaws.com"
                },
                "Action": "SQS:SendMessage",
                "Resource": aws_sqs_queue.sms_queue.arn ,
                "Condition": {
                    "ArnLike": {
                        "aws:SourceArn": aws_sns_topic.notification_topic.arn
                    }
                }
            }
        ]
    })
}