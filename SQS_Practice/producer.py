import boto3
import os
import json
import logging
import time
import uuid

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL', "https://sqs.ap-northeast-2.amazonaws.com/211125350993/url2png-timangs")
AWS_REGION = os.environ.get('AWS_REGION', 'ap-northeast-2')

sqs = boto3.client('sqs', region_name=AWS_REGION)


def send_message(message_body):
    """SQS 큐에 메시지를 전송합니다."""
    try:
        response = sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(message_body),
        )
        logging.info(f"메시지 전송 성공: {response['MessageId']}")
        return response['MessageId']
    except Exception as e:
        logging.error(f"메시지 전송 실패: {e}")
        return None


if __name__ == "__main__":
    message = {
        "url": "http://aws.amazon.com",
        "timestamp": time.time()
    }
    send_message(message)
    logging.info("메시지 전송 완료")