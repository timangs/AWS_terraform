# outputs.tf (수정됨)

output "kops_ec2_instance_id" {
  description = "ID of the kops EC2 instance"
  value       = aws_instance.kops_ec2.id
}

# Output the Public IP address directly from the instance
output "kops_ec2_public_ip" {
  description = "Public IP address of the kops EC2 instance"
  value       = aws_instance.kops_ec2.public_ip # Get public IP from instance resource
}

output "kops_ec2_private_ip" {
  description = "Private IP address of the kops EC2 instance"
  value       = aws_instance.kops_ec2.private_ip
}

output "ssh_command" {
  description = "Command to SSH into the kops EC2 instance"
  value       = "ssh -i <path_to_your_private_key> ec2-user@${aws_instance.kops_ec2.public_ip}" # Use instance public IP
}

output "kops_state_store_info" {
  description = "kOps state store bucket"
  value       = "s3://${var.s3_state_store}"
}

output "kops_cluster_name_info" {
  description = "kOps cluster name"
  value       = var.cluster_base_name
}
