# primary Queue setup
resource "aws_sqs_queue" "primary_dlq" {
    name = "primary_dlq"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}

resource "aws_sqs_queue" "primary_queue" {
    name = "primary_queue"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
    

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.primary_dlq.arn
        maxReceiveCount     = 3
    })
  
}



# email,whatsapp,sms queues

# emailing queue
resource "aws_sqs_queue" "email_dlq" {
    name = "email_dlq"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}

resource "aws_sqs_queue" "email_queue" {
    name = "email_queue"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
    

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
        maxReceiveCount     = 3
    })
  
}


# whatsapp queue
resource "aws_sqs_queue" "whatsapp_dlq" {
    name = "whatsapp_dlq"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}

resource "aws_sqs_queue" "whatsapp_queue" {
    name = "whatsapp_queue"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
    

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.whatsapp_dlq.arn
        maxReceiveCount     = 3
    })
  
}


# sms queue
resource "aws_sqs_queue" "sms_dlq" {
    name = "sms_dlq"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}

resource "aws_sqs_queue" "sms_queue" {
    name = "sms_queue"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
    

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.sms_dlq.arn
        maxReceiveCount     = 3
    })
  
}



# Dead letter queue for sns
resource "aws_sqs_queue" "sns_dlq" {
    name = "SNS_dlq"
    visibility_timeout_seconds = 60
    message_retention_seconds = 345600
}