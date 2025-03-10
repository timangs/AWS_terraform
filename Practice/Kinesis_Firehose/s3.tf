resource "random_string" "random_suffix" {
  length           = 5
  special          = false # 특수 문자 사용 안 함
  upper            = false
  lower            = true # 소문자
  numeric          = true
}

resource "aws_s3_bucket" "" {
  bucket = "firehose-stream-${random_string.random_suffix.result}"
  force_destroy = true
}