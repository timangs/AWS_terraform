# data.tf (Route 53 Zone 조회 추가)

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  first_available_az = data.aws_availability_zones.available.names[0]
}

data "aws_ssm_parameter" "latest_amzn_linux_ami" {
  name = var.latest_ami_id_parameter_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Data source to get the existing Route 53 hosted zone ID
data "aws_route53_zone" "existing" {
  name         = var.existing_hosted_zone_name
  private_zone = false # Ensure it's a public zone
}
