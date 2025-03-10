resource "aws_kinesis_stream" "stream" {
  name        = "kinesis-stream"
  shard_count = 1
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "firehose-stream"
  destination = "extended_s3" 
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.firehose_bucket.arn
    buffering_size = 5
    buffering_interval = 60
    compression_format = "GZIP"
    prefix             = "/"
    error_output_prefix = "logs/"
  }
}
