
resource "aws_dynamodb_table" "table" {
  name           = "Music" # DynamoDB 테이블 이름
  hash_key       = "Artist"              # 파티션 키 (필수)
  range_key  = "SongTitle"
  attribute {
    name = "Artist"
    type = "S"
  }
  attribute {
    name = "SongTitle"
    type = "S"
  }
  billing_mode   = "PAY_PER_REQUEST" 
  tags = {
    Name        = "My DynamoDB Table"
    Environment = "Dev"
  }
}