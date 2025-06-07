import os
import json
import boto3
import datetime
import smtplib
from email.mime.text import MIMEText

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('DailyEmailLimit')

# Rate limit constant
MAX_EMAILS_PER_DAY = 500

def is_allowed_today():
    """Check and increment today's email count in DynamoDB."""
    now = datetime.datetime.utcnow()
    key = now.strftime("email_%Y%m%d")  # e.g., email_20250607
    ttl = int(now.replace(hour=23, minute=59, second=59).timestamp())

    try:
        response = table.update_item(
            Key={'id': key},
            UpdateExpression="ADD #count :inc SET #ttl = :ttl",
            ExpressionAttributeNames={
                "#count": "count",
                "#ttl": "ttl"  # <-- aliasing the reserved word
            },
            ExpressionAttributeValues={
                ':inc': 1,
                ':ttl': ttl
            },
            ReturnValues="UPDATED_NEW"
        )
        count = response['Attributes']['count']
        return count <= MAX_EMAILS_PER_DAY
    except Exception as e:
        print(f"Error accessing DynamoDB: {e}")
        return False

def send_email_smtp(to_email,subject, body):
    """Send email using SMTP."""
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = os.environ['FROM_EMAIL']
    msg['To'] = to_email

    with smtplib.SMTP(os.environ['SMTP_HOST'], int(os.environ['SMTP_PORT'])) as server:
        server.starttls()
        server.login(os.environ['SMTP_USER'], os.environ['SMTP_PASS'])
        server.sendmail(msg['From'], [to_email], msg.as_string())

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            sns_payload = json.loads(record['body'])
            print("SNS Payload:", sns_payload)

            # Then decode the actual message from SNS
            inner_message = json.loads(sns_payload['Message'])
            print("Inner Message:", inner_message)

            to = inner_message['receiver_email']
            subject = f"{inner_message['messageType']} Notification from {inner_message['sender_name']}"
            body = inner_message['message']

            if is_allowed_today():
                send_email_smtp(to, subject, body)
                print(f"✅ Email sent to {to}")
            else:
                print("🚫 Daily email limit reached. Skipping email.")
        except Exception as e:
            print(f"❌ Failed to process record: {e}")
