import json
import boto3
import os

sns=boto3.client('sns')
# SNS_TOPIC_ARN='arn:aws:sns:us-east-1:442426858328:NotificationTopic'
SNS_TOPIC_ARN=os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    for record in event['Records']:
        message = record['body']
        json_message = json.loads(message)
        try:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message,
                MessageAttributes={
                    'notificationType': {
                        'DataType': 'String',
                        'StringValue': json_message['notificationType']
                    }
                },
                Subject="New Notification"
            )
            print(f"succesfully published to sns for {message}")
        except Exception as e:
            print(f"Error publishing to SNS: {e}")
            raise e  # Raising ensures the message is retried
    return {"status": "messages forwarded to SNS"}
