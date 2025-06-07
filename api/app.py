from fastapi import FastAPI,HTTPException
from pydantic import BaseModel, EmailStr, constr
import boto3
from mypy_boto3_sqs import SQSClient
import os



app=FastAPI()

# Aws client setup
sqs:SQSClient=boto3.client('sqs')
# primary_queue_url="https://sqs.us-east-1.amazonaws.com/442426858328/primary-queue"
primary_queue_url="https://sqs.us-east-1.amazonaws.com/442426858328/primary_queue"


class Message(BaseModel):
    sender_name:str
    sender_email:EmailStr
    sender_phone:constr(min_length=10, max_length=10)
    receiver_name:str
    receiver_email: EmailStr
    receiver_phone:constr(min_length=10, max_length=10)
    messageType:str 
    message:str
    notificationType:str


@app.post("/send")
def send_message(msg:Message):
    try:
        message_body=msg.json()
        response=sqs.send_message(
            QueueUrl=primary_queue_url,
            MessageBody=message_body
        )                           
        return {"message_id":response["MessageId"]}                                                   
    except Exception as e:
        raise HTTPException(status_code=500,detail=f"failed to send message:{e}")

