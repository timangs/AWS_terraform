resource "aws_glue_catalog_database" "default_db" {
  name = "default"
}

resource "aws_athena_workgroup" "workgroup" {
  name = "workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_log_bucket.bucket}/query_results/" 
    }
  }
}
resource "aws_athena_named_query" "create_alb_access_logs_table" {
  name        = "create_alb_access_logs_table"
  database    = aws_glue_catalog_database.default_db.name //  "default" 사용
  workgroup   = aws_athena_workgroup.workgroup.name
  description = "Creates the alb_access_logs table"
  query       = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS alb_access_logs (
    type string,
    time string,
    elb string,
    client_ip string,
    client_port int,
    target_ip string,
    target_port int,
    request_processing_time double,
    target_processing_time double,
    response_processing_time double,
    elb_status_code int,
    target_status_code string,
    received_bytes bigint,
    sent_bytes bigint,
    request_verb string,
    request_url string,
    request_proto string,
    user_agent string,
    ssl_cipher string,
    ssl_protocol string,
    target_group_arn string,
    trace_id string,
    domain_name string,
    chosen_cert_arn string,
    matched_rule_priority string,
    request_creation_time string,
    actions_executed string,
    redirect_url string,
    lambda_error_reason string,
    target_port_list string,
    target_status_code_list string,
    classification string,
    classification_reason string,
    conn_trace_id string
)
PARTITIONED BY (
    year STRING,
    month STRING,
    day STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    'serialization.format' = '1',
    'input.regex' = 
        '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^\s]+?)\" \"([^\s]+)\" \"([^ ]*)\" \"([^ ]*)\" ?([^ ]*)?( .*)?'
)
LOCATION 's3://${aws_s3_bucket.athena_log_bucket.bucket}/elb_log/AWSLogs/${aws_vpc.vpc.owner_id}/elasticloadbalancing/ap-northeast-2/'
TBLPROPERTIES (
    "projection.enabled" = "true",
    "projection.year.type" = "integer",
    "projection.month.type" = "integer",
    "projection.day.type" = "integer",
    "projection.year.range" = "2025,2026",
    "projection.month.range" = "1,12",
    "projection.day.range" = "1,31",
    "projection.year.format" = "yyyy",
    "projection.month.format" = "MM",
    "projection.day.format" = "dd",
    "projection.year.interval" = "1",
    "projection.month.interval" = "1",
    "projection.day.interval" = "1",
    "projection.year.interval.unit" = "YEARS",
    "projection.month.interval.unit" = "MONTHS",
    "projection.day.interval.unit" = "DAYS",
    "storage.location.template" = "s3://${aws_s3_bucket.athena_log_bucket.bucket}/elb_log/AWSLogs/${aws_vpc.vpc.owner_id}/elasticloadbalancing/ap-northeast-2/${year}/${month}/${day}"
);
EOF
}

data "aws_athena_query_result" "alb_logs_query" {
  query_execution_id = aws_athena_query_execution.run_query.id
  depends_on = [aws_athena_named_query.create_alb_access_logs_table]

}

resource "aws_athena_query_execution" "run_query" {
    query = "select * from default.alb_access_logs where month='03' and day = '06';" # 쿼리 실행
    workgroup = aws_athena_workgroup.workgroup.name
    
      query_execution_context {
        database = aws_glue_catalog_database.default_db.name
  }
}

output "alb_logs" {
  value = data.aws_athena_query_result.alb_logs_query.result_rows
  description = "The results of the Athena query."
}