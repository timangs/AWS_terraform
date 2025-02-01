# resource "aws_route53_resolver_rule" "inbound_rule" {
#   provider = aws.singa
#   domain_name = "awssinga.internal"
#   target_ip {
#     ip = "10.3.3.250"  
#   }
#   target_ip {
#     ip = "10.3.4.250"  
#   }
#   rule_type = "FORWARD"
#   resolver_endpoint_id = module.singa.outbound_endpoint_id
#   name = "singa-inbound-rule"
# }

# resource "aws_route53_resolver_rule_association" "inbound_association" {
#   provider = aws.singa
#   resolver_rule_id = aws_route53_resolver_rule.inbound_rule.id
#   vpc_id           = module.idc-singa.vpc_id
# }
