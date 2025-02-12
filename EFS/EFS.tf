resource "aws_efs_file_system" "idc_efs" {
  creation_token = "EFS-A"
  performance_mode = "generalPurpose"  # 성능 모드 "generalPurpose|maxIO"
  throughput_mode = "bursting"       # 처리량 모드 "bursting|provisioned|elastic"
  encrypted  = true
  # kms_key_id = "arn:aws:kms:..."
  lifecycle_policy {
    transition_to_ia          = "AFTER_30_DAYS" 
    transition_to_archive     = null
    transition_to_primary_storage_class = null
  }
    tags = {
    Name = "idc_efs"
  }
}

resource "aws_efs_backup_policy" "idc_efs_backup" {
  file_system_id = aws_efs_file_system.idc_efs.id

  backup_policy {
    status = "DISABLED"
  }
}

resource "aws_efs_mount_target" "idc_efs_target" {
  file_system_id = aws_efs_file_system.idc_efs.id
  for_each = {
    idc1 = {subnet_id=aws_subnet.idc_subnet["idc1"].id}
    idc2 = {subnet_id=aws_subnet.idc_subnet["idc2"].id}
    idc3 = {subnet_id=aws_subnet.idc_subnet["idc3"].id}
  }
  subnet_id      = each.value.subnet_id
  security_groups = [aws_security_group.idc_securitygroup.id]
}