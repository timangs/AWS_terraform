resource "aws_api_gateway_rest_api" "github_api" {
  name        = "GitHubAPI"
  description = "API Gateway forwarding requests to GitHub API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# "/hello" 리소스 추가
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.github_api.id
  parent_id   = aws_api_gateway_rest_api.github_api.root_resource_id
  path_part   = "hello"
}

# "/hello/{userid}" 리소스 추가
resource "aws_api_gateway_resource" "userid_resource" {
  rest_api_id = aws_api_gateway_rest_api.github_api.id
  parent_id   = aws_api_gateway_resource.hello_resource.id
  path_part   = "{userid}"
}

# GET 메서드 추가 (`/hello/{userid}`)
resource "aws_api_gateway_method" "get_userid" {
  rest_api_id   = aws_api_gateway_rest_api.github_api.id
  resource_id   = aws_api_gateway_resource.userid_resource.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.userid" = true
  }
}

# GitHub API 연동
resource "aws_api_gateway_integration" "github_integration" {
  rest_api_id             = aws_api_gateway_rest_api.github_api.id
  resource_id             = aws_api_gateway_resource.userid_resource.id
  http_method             = aws_api_gateway_method.get_userid.http_method
  integration_http_method = "GET"
  type                    = "HTTP"  

  # GitHub API 요청 URL에 {userid} 포함
  uri = "https://api.github.com/users/{userid}"

  # API Gateway에서 {userid} 값을 GitHub API로 전달
  request_parameters = {
    "integration.request.path.userid" = "method.request.path.userid"
    "integration.request.header.User-Agent" = "'AWS-APIGateway-Proxy'"
  }

  passthrough_behavior = "WHEN_NO_MATCH"  # 패스스루 설정 (콘텐츠 처리 방식)
  connection_type      = "INTERNET"       # 외부 API 호출 가능하도록 설정
}

# API 응답 매핑 추가 (500 오류 방지)
resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.github_api.id
  resource_id = aws_api_gateway_resource.userid_resource.id
  http_method = aws_api_gateway_method.get_userid.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.github_api.id
  resource_id = aws_api_gateway_resource.userid_resource.id
  http_method = aws_api_gateway_method.get_userid.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# API 배포
resource "aws_api_gateway_deployment" "github_api_deployment" {
  depends_on  = [aws_api_gateway_integration.github_integration]
  rest_api_id = aws_api_gateway_rest_api.github_api.id
}

# dev 스테이지 생성
resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.github_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.github_api.id
  stage_name    = "dev"
}

# API 엔드포인트 출력
output "github_api_endpoint" {
  value = "${aws_api_gateway_stage.dev_stage.invoke_url}/hello/timang"
}