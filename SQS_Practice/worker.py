import boto3
import os
import json
import logging
import time

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL', "https://sqs.ap-northeast-2.amazonaws.com/211125350993/url2png-timangs")
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME', "sqs-timangs-seoul")
AWS_REGION = os.environ.get('AWS_REGION', 'ap-northeast-2')

sqs = boto3.client('sqs', region_name=AWS_REGION)
s3 = boto3.client('s3', region_name=AWS_REGION)


def process_message(message):
    """메시지를 처리하고 S3에 관련 작업을 수행합니다. (예시)"""
    try:
        body = json.loads(message['Body'])
        url = body['url']
        timestamp = body['timestamp']

        s3_key = f"processed/{os.path.basename(url)}_{timestamp}.txt"
        s3.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=s3_key,
            Body=f"URL: {url}\nTimestamp: {timestamp}".encode('utf-8')
        )
        logging.info(f"S3 업로드 완료: {s3_key}")
        return True 

    except Exception as e:
        print(". ",end="")
        return False  


def receive_messages():
    """SQS 큐에서 메시지를 수신하고 처리합니다."""
    while True:
        try:
            response = sqs.receive_message(
                QueueUrl=SQS_QUEUE_URL,
                MaxNumberOfMessages=1,  # 한 번에 최대 1개 메시지 수신
                WaitTimeSeconds=10  # Long Polling (최대 10초 대기)
            )

            if 'Messages' in response:
                for message in response['Messages']:
                    if process_message(message):  
                        sqs.delete_message(
                            QueueUrl=SQS_QUEUE_URL,
                            ReceiptHandle=message['ReceiptHandle']
                        )
                        logging.info(f"메시지 삭제 완료: {message['MessageId']}")
            else:
                logging.info("수신된 메시지 없음")

        except Exception as e:
            logging.error(f"메시지 수신 실패: {e}")
            time.sleep(5)  
if __name__ == "__main__":
    logging.info("Worker 시작. 메시지 수신 대기...")
    receive_messages()