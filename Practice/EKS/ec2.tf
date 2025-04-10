# ec2.tf (Hosted Zone ID 전달)

resource "aws_instance" "kops_ec2" {
  ami           = data.aws_ssm_parameter.latest_amzn_linux_ami.value
  instance_type = "t3.small"
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = aws_subnet.my_public_sn.id
  associate_public_ip_address = true
  private_ip                  = "10.0.0.10"
  vpc_security_group_ids      = [aws_security_group.kops_ec2_sg.id]

  # Attach the IAM instance profile
  iam_instance_profile = aws_iam_instance_profile.kops_ec2_profile.name

  # Render the UserData script from the template file
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    # Pass necessary variables to the template
    k8s_version                   = var.kubernetes_version
    aws_default_region            = data.aws_region.current.name
    aws_account_id                = data.aws_caller_identity.current.account_id
    kops_cluster_name             = var.cluster_base_name
    kops_state_store_bucket       = var.s3_state_store
    kops_az1                      = var.availability_zone_1
    kops_az2                      = var.availability_zone_2
    kops_master_instance_type     = var.master_node_instance_type
    kops_worker_instance_type     = var.worker_node_instance_type
    kops_worker_node_count        = var.worker_node_count
    kops_vpc_cidr                 = var.vpc_block
    kops_release_tag              = "v1.28.7"
    hosted_zone_id                = data.aws_route53_zone.existing.zone_id # ADDED: Pass the zone ID
  })

  user_data_replace_on_change = true

  tags = merge(var.instance_tags, {
    Name = "kops-ec2"
  })

  depends_on = [
    aws_internet_gateway.my_igw,
    aws_iam_instance_profile.kops_ec2_profile
  ]
}
