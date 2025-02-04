output "subnet1_id" {
  value = aws_subnet.singa["sn1"].id
}
output "vpc_id" {
  value = aws_vpc.singa.id
}

# route for transit gateway
output "rt_id" {
  value = aws_route_table.singa["public"].id
}
output "vpn_rt_id" {
  value = aws_route_table.singa["vpn"].id
}

output "outbound_endpoint_id" {
  value = aws_route53_resolver_endpoint.outbound.id
}
