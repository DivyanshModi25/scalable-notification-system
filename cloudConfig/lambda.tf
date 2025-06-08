# lambda function (primary queue sqs -> sns)
resource "aws_lambda_function" "sqs_to_sns_lambda" {
    function_name = "SQSMessageToSNS"
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