resource "aws_backup_vault" "backup" {
  name = "test-vault"
  # 기본 키를 사용할 때는 kms_key_arn을 지정하지 않으면 됩니다.
  tags = {
    Name = "test-vault"
  }
  force_destroy = true
}

resource "aws_backup_plan" "backup_plan_01" {
  name = "backup_plan_01"

  rule {
    rule_name         = "backup_plan_01"
    target_vault_name = aws_backup_vault.backup.name
    schedule          = "cron(10 7 * * ? *)" #오후 4시 10분
    start_window      = 60    #1시간
    completion_window = 10080 #7일

    lifecycle {
      cold_storage_after = null # cold storage 사용 안 함
      delete_after       = 35  # 35일 후 삭제
    }
    enable_continuous_backup = false
  }
  tags = {
    Name = "backup_plan_01"
  }
}

data "aws_iam_role" "backup_role" {
  name = "AWSBackupDefaultServiceRole"
}

resource "aws_backup_selection" "instance_selection" {
  plan_id      = aws_backup_plan.backup_plan_01.id
  name         = "instance-selection"
  iam_role_arn = data.aws_iam_role.backup_role.arn

  resources = [
    aws_instance.aws_con_instance.arn
  ]
}