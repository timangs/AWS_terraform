# variables.tf (Route 53 관련 수정)

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default = "Instance-key"
}

variable "sg_ingress_ssh_cidr" {
  description = "The IP address range that can be used to SSH to the EC2 instances."
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(regex("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})$", var.sg_ingress_ssh_cidr))
    error_message = "Must be a valid IP CIDR range of the form x.x.x.x/x."
  }
}

variable "latest_ami_id_parameter_name" {
  description = "SSM Parameter name for the latest Amazon Linux 2 AMI ID"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "kubernetes_version" {
  description = "Enter Kubernetes Version, e.g., 1.24.12"
  type        = string
  default     = "1.24.12"
}

variable "cluster_base_name" {
  description = "kOps ClusterName. Should be a subdomain of your existing hosted zone (e.g., kops.timangs.shop)"
  type        = string
  default     = "kops.timangs.shop" # Default updated to reflect usage with timangs.shop
}

variable "existing_hosted_zone_name" {
  description = "The name of the existing Route 53 public hosted zone."
  type        = string
  default     = "timangs.shop." # Note the trailing dot for exact match
}

variable "s3_state_store" {
  description = "S3 Bucket Name (KOPS_STATE_STORE)"
  type        = string
  default     = "pkos-kops-s3-timangs"
}

variable "master_node_instance_type" {
  description = "EC2 Instance Type for Master Nodes. Default is t3.medium."
  type        = string
  default     = "t3.medium"
}

variable "worker_node_instance_type" {
  description = "EC2 Instance Type for Worker Nodes. Default is t3.medium."
  type        = string
  default     = "t3.medium"
}

variable "worker_node_count" {
  description = "Worker Node Counts"
  type        = number
  default     = 2
}

variable "vpc_block" {
  description = "AWS kOps VPC CIDR"
  type        = string
  default     = "172.30.0.0/16"
}

variable "target_region" {
  description = "Target AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zone_1" {
  description = "First Availability Zone for kOps Cluster"
  type        = string
  default     = "ap-northeast-2a"
}

variable "availability_zone_2" {
  description = "Second Availability Zone for kOps Cluster"
  type        = string
  default     = "ap-northeast-2c"
}

variable "instance_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Project   = "PKOS-kOps"
    ManagedBy = "Terraform"
  }
}

variable "ec2_admin_role_name" {
  description = "Name of the existing IAM role to attach to the EC2 instance"
  type        = string
  default     = "_ec2_admin"
}
