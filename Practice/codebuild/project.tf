resource "aws_codebuild_project" "flask_app" {
  name          = "flask-app-build"
  description   = "Builds and tests the Flask application"
  build_timeout = "10"  # 빌드 시간 제한 (분). 필요에 따라 조정.
  service_role  = aws_iam_role.codebuild_role.arn # IAM 역할

  artifacts {
    type = "NO_ARTIFACTS"  # S3에 아티팩트를 저장하지 않음. 필요에 따라 "S3"로 변경.
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL" # 빌드 인스턴스 타입
    image                       = "aws/codebuild/standard:7.0"  # CodeBuild 이미지. Python 버전 확인.
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false  # Docker in Docker를 사용하지 않으면 false

  }

  source {
    type            = "GITHUB" # 또는 CODECOMMIT, S3 등
    location        = "https://github.com/timangs/log_application.git"  # GitHub 리포지토리 URL
    git_clone_depth = 1  # 얕은 복제 (최신 커밋만 가져옴)
    buildspec       = "buildspec.yml" # buildspec 파일 경로 (기본값: buildspec.yml)
  }

    logs_config {
        cloudwatch_logs {
          group_name = "codebuild-flask-app" # CloudWatch Logs 그룹 이름 (선택 사항)
          # stream_name = "build-stream"  # (선택 사항) CloudWatch Logs 스트림 이름
        }
   }
}

# IAM Role (CodeBuild에 필요한 권한)
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-flask-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy (CodeBuild 권한)
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-flask-app-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",       # S3에 아티팩트 저장 시 필요
          "ecr:GetAuthorizationToken", # ECR 관련 권한 (Docker 사용 시)
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "codebuild:CreateReportGroup", # 테스트 리포트 관련
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"

        ]
        Effect   = "Allow"
        Resource = "*" # 필요에 따라 리소스 제한
      },
       # (ECS/Fargate, CodeDeploy 배포에 필요한 권한 추가)
    ]
  })
}