# iam.tf (신규)

# Create an IAM instance profile and attach the existing role to it.
# The EC2 instance will assume this role.
resource "aws_iam_instance_profile" "kops_ec2_profile" {
  name = "${var.cluster_base_name}-kops-ec2-profile" # Instance profile name
  role = var.ec2_admin_role_name                     # Name of the existing IAM role (_ec2_admin)

  tags = var.instance_tags
}

# Note: This assumes the IAM role specified by var.ec2_admin_role_name already exists
# and has the necessary permissions for kOps and other operations in the UserData script.
# Required permissions typically include ec2:*, s3:*, iam:*, route53:*, autoscaling:*, elasticloadbalancing:*, etc.
# Also ensure the role's trust policy allows the EC2 service (ec2.amazonaws.com) to assume it.
