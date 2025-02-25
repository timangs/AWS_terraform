# data "aws_vpc_endpoint" "endpoint" {
#   id = aws_vpc_endpoint.datasync_endpoint.id
# }

# data "aws_network_interface" "enis" {
#   for_each = toset(data.aws_vpc_endpoint.endpoint.network_interface_ids)
#   id       = each.value
# }

# output "vpc_endpoint_private_ips" {
#   value = {
#     for k, v in data.aws_network_interface.enis : k => v.private_ip
#   }
# }

# data "http" "activation_key" {
# #     url = "http://10.1.1.100/activation-key?gatewayType=SYNC&activationRegion=ap-northeast-2&endpointType=PUBLIC&no_redirect" # Agent VM IP 주소와 리전 등으로 변경
#     url = "http://${aws_instance.aws_instance_datasync1.public_ip}/activation-key?gatewayType=SYNC&activationRegion=ap-northeast-2&privateLinkEndpoint=${vpc_endpoint_private_ips[0]}&endpointType=PRIVATE_LINK&no_redirect"
# }


# resource "aws_datasync_agent" "agent" {
#   name          = "datasync-agent"  # 에이전트 이름
#   ip_address    = "10.1.1.100"
#   activation_key = data.http.activation_key.body 
#   #vpc endpoint 사용시
#   vpc_endpoint_id = aws_vpc_endpoint.datasync_endpoint.id #VPC Endpoint ID
#   subnet_arns      = [aws_subnet.aws_subnet["aws1"].arn]  # DataSync Agent가 위치할 서브넷
#   security_group_arns = [aws_security_group.aws_securitygroup.arn]
#   tags = {
#     Name = "my-datasync-agent"
#   }
# }

# # Destination EFS (VPC B)
# resource "aws_datasync_location_efs" "destination_efs_location" {
#     efs_file_system_arn = data.aws_efs_file_system.

#     ec2_config {
#     subnet_arn         = "arn:aws:ec2:${data.aws_efs_file_system.destination_efs.availability_zone_name}:${split(":", var.vpc_b_efs_arn)[4]}:subnet/${var.vpc_b_subnet_id}"  #VPC B의 서브넷 ID
#     security_group_arns = [var.vpc_b_efs_security_group_arn] #VPC B EFS의 보안그룹
#   }
#     tags = {
#       Name = "datasync-destination-efs"
#     }
# }

# # --- (6) DataSync Task ---

# resource "aws_datasync_task" "efs_to_efs" {
#   source_location_arn      = aws_datasync_location_efs.source_efs_location.arn
#   destination_location_arn = aws_datasync_location_efs.destination_efs_location.arn
#   name                     = "efs-to-efs-datasync-task"

#  options {
#     verify_mode   = "POINT_IN_TIME_CONSISTENT"
#     atime         = "BEST_EFFORT"
#     mtime         = "PRESERVE"
#     # 필요에 따라 다른 옵션 추가
#   }
#     tags = {
#         Name = "efs-to-efs-datasync-task"
#     }
# }