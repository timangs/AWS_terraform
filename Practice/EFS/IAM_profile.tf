data "aws_iam_role" "temp_role" {
  name = "_EC2_ReadOnly"  
}

resource "aws_iam_instance_profile" "temp_role" {
  name = "temp_role-profile"
  role = data.aws_iam_role.temp_role.name 
}

data "aws_iam_role" "datasync_role" {
  name = "_EC2_DataSyncFullAccess"  
}

resource "aws_iam_instance_profile" "datasync_role" {
  name = "datasync_role-profile"
  role = data.aws_iam_role.temp_role.name 
}