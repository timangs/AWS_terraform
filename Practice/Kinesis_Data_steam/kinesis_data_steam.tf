resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "kinesis_stream"
  shard_count      = 1
  retention_period = 24 #시간 단위, 기본값은 24
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}