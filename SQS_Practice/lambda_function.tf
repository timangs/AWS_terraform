# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "lambda_function/"  # Lambda 함수 코드가 있는 디렉토리
#   output_path = "lambda_function.zip"
# }

# # Lambda 함수 생성
# resource "aws_lambda_function" "my_lambda" {
#   filename      = "lambda_function.zip"
#   function_name = "my-lambda-function"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "main.handler"  # Python: 파일명.함수명 (예: main.py의 handler 함수)
#   runtime       = "python3.13"
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256

#   # 환경 변수 (선택 사항)
#   environment {
#     variables = {
#       MY_VARIABLE = "some_value"
#     }
#   }
# }