import boto3
import json

# Kinesis 클라이언트 생성
kinesis_client = boto3.client('kinesis', region_name='ap-northeast-2')
stream_name = "kinesis_stream"

# 스트림의 샤드 확인
shard_response = kinesis_client.describe_stream(StreamName=stream_name)
shard_id = shard_response['StreamDescription']['Shards'][0]['ShardId']

# 샤드에서 데이터를 가져오는 Shard Iterator 생성
shard_iterator_response = kinesis_client.get_shard_iterator(
    StreamName=stream_name,
    ShardId=shard_id,
    ShardIteratorType='LATEST'
)

shard_iterator = shard_iterator_response['ShardIterator']

print("Listening for new records...")

while True:
    # 데이터 가져오기
    records_response = kinesis_client.get_records(ShardIterator=shard_iterator, Limit=10)
    records = records_response['Records']

    for record in records:
        data = json.loads(record['Data'])
        print(f"Received: {data}")

    # 다음 Shard Iterator 갱신
    shard_iterator = records_response['NextShardIterator']
