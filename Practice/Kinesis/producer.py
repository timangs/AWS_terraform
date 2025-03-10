import boto3
import json
import time
# Kinesis 클라이언트 생성
kinesis_client = boto3.client('kinesis', region_name='ap-northeast-2')
stream_name = "kinesis_stream"
# 데이터 스트림에 샘플 데이터 전송
for i in range(20):
    data = {"id": i, "message": f"Hello from Producer {i}"}
    response = kinesis_client.put_record(
        StreamName=stream_name,
        Data=json.dumps(data),
        PartitionKey=str(i)
    )
    print(f"Sent: {data}, Response: {response['SequenceNumber']}")
    time.sleep(1)  # 1초 간격으로 데이터 전송
