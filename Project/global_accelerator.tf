# resource "aws_globalaccelerator_accelerator" "main" {
#   name            = "my-global-accelerator"
#   ip_address_type = "IPV4"
#   enabled         = true
# }

# resource "aws_globalaccelerator_listener" "http" {
#   accelerator_arn = aws_globalaccelerator_accelerator.main.id
#   client_affinity = "NONE"
#   protocol        = "TCP"
#   port_range {
#     from_port = 80
#     to_port   = 80
#   }
# }

# resource "aws_globalaccelerator_endpoint_group" "seoul" {
#   listener_arn = aws_globalaccelerator_listener.http.id
#   endpoint_group_region = "ap-northeast-2" # 서울 리전

#   endpoint_configuration {
#     endpoint_id = aws_instance.ase_instance_web1.id # 서울 리전 EC2 인스턴스 ID
#     weight = 128
#     client_ip_preservation_enabled = true
#   }

#   health_check_port     = 80
#   health_check_protocol = "TCP"
#   threshold_count       = 3
# }

# resource "aws_globalaccelerator_endpoint_group" "singapore" {
#   listener_arn = aws_globalaccelerator_listener.http.id
#   endpoint_group_region = "ap-southeast-1" # 싱가폴 리전

#   endpoint_configuration {
#     endpoint_id = aws_instance.asi_instance_web1.id # 싱가폴 리전 EC2 인스턴스 ID
#     weight = 128
#     client_ip_preservation_enabled = true
#   }

#   health_check_port     = 80
#   health_check_protocol = "TCP"
#   threshold_count       = 3
# }