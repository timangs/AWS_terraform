import boto3
import os
import json
import logging
import time
import uuid

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 환경 변수에서 설정 가져오기
SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL', "https://sqs.ap-northeast-2.amazonaws.com/211125350993/url2png-timangs")
AWS_REGION = os.environ.get('AWS_REGION', 'ap-northeast-2')

# SQS 클라이언트 생성
sqs = boto3.client('sqs', region_name=AWS_REGION)


def send_message(message_body):
    """SQS 큐에 메시지를 전송합니다."""
    try:
        response = sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(message_body),  # 메시지 본문은 JSON 형식
            # MessageGroupId='MyMessageGroup',  # Standard 큐에서는 필요 없음
            # MessageDeduplicationId=str(uuid.uuid4())  # Standard 큐에서는 필요 없음
        )
        logging.info(f"메시지 전송 성공: {response['MessageId']}")
        return response['MessageId']
    except Exception as e:
        logging.error(f"메시지 전송 실패: {e}")
        return None


if __name__ == "__main__":
    # URL을 메시지에 포함하여 전송
    message = {
        "url": "http://aws.amazon.com",  # 처리할 URL
        "timestamp": time.time()
    }
    send_message(message)
    logging.info("메시지 전송 완료")