# SNS
resource "aws_sns_topic" "notification_topic" {
  name = "notificationTopic"
}



# email,whasapp and sms queue subscription to sns

resource "aws_sns_topic_subscription" "email_sub" {
    topic_arn = aws_sns_topic.notification_topic.arn
    protocol = "sqs"
    endpoint = aws_sqs_queue.email_queue.arn
    filter_policy = jsonencode({
      "notificationType": [
        "email",
        "All"
      ]
    })
    redrive_policy = jsonencode({
      deadLetterTargetArn=aws_sqs_queue.sns_dlq.arn 
    })
  
}


resource "aws_sns_topic_subscription" "whatsapp_sub" {
    topic_arn = aws_sns_topic.notification_topic.arn
    protocol = "sqs"
    endpoint = aws_sqs_queue.whatsapp_queue.arn
    filter_policy = jsonencode({
      "notificationType": [
        "whatsapp",
        "All"
      ]
    })
    redrive_policy = jsonencode({
      deadLetterTargetArn=aws_sqs_queue.sns_dlq.arn 
    })
  
}


resource "aws_sns_topic_subscription" "sms_sub" {
    topic_arn = aws_sns_topic.notification_topic.arn
    protocol = "sqs"
    endpoint = aws_sqs_queue.sms_queue.arn
    filter_policy = jsonencode({
      "notificationType": [
        "sms",
        "All"
      ]
    })
    redrive_policy = jsonencode({
      deadLetterTargetArn=aws_sqs_queue.sns_dlq.arn 
    })
  
}