resource "random_id" "bucket_suffix" {
  byte_length = 6
}
resource "aws_s3_bucket" "athena_log_bucket" {
  bucket = "athena-${random_id.bucket_suffix.hex}" # 버킷 이름
  # lifecycle {
  #   prevent_destroy = true  # 중요: 실수로 버킷이 삭제되는 것을 방지
  # }
    force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_access_log_bucket_policy" {
  bucket = aws_s3_bucket.athena_log_bucket.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::600734575887:root"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.athena_log_bucket.arn}/elb_log/AWSLogs/211125350993/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service" = "delivery.logs.amazonaws.com"
        # "Service": "logdelivery.elb.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.athena_log_bucket.arn}"
    }
  ]
  })
}