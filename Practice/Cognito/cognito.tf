resource "aws_cognito_user_pool" "pool" {
  name = "user-pool"

  # 기본값 (Cognito 콘솔에서 생성 시)
  auto_verified_attributes = ["email"]  # 이메일 자동 확인 (기본값은 아님.  필요하면 추가)
  username_attributes = ["email"]
  mfa_configuration = "OFF"        # MFA (Multi-Factor Authentication) - 기본값: OFF

  # Password Policy (Cognito 콘솔 기본값)
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

   # Email Verification (Cognito 콘솔 기본 설정과 유사하게)
    account_recovery_setting {
      recovery_mechanism {
          name = "verified_email"
          priority = 1
      }
    }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"  // 또는 "DEVELOPER"
    # DEVELOPER 모드를 사용하는 경우:
    # source_arn          = "arn:aws:ses:YOUR_REGION:YOUR_ACCOUNT_ID:identity/your-verified-domain.com"  # SES에서 인증된 도메인/이메일 ARN
    # from_email_address  = "noreply@your-verified-domain.com"
    # reply_to_email_address = "support@your-verified-domain.com"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "app-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret = false
  refresh_token_validity = 30
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

    explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH","ALLOW_ADMIN_USER_PASSWORD_AUTH","ALLOW_CUSTOM_AUTH"]

  # 로컬 개발 환경을 위한 콜백/로그아웃 URL (나중에 실제 URL로 변경해야 함!)
  callback_urls = ["https://main.d214ibimaxg1eb.amplifyapp.com/callback"]
  logout_urls   = ["https://main.d214ibimaxg1eb.amplifyapp.com/logout"]
}
