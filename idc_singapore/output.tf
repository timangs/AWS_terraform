output "vpc_id" {
  value = aws_vpc.idc-singa.id
}
output "subnet_id" {
  value = aws_subnet.idc-singa.id
}
output "route_table_id" {
  value = aws_route_table.idc-singa.id
  depends_on = [ aws_route_table.idc-singa ]
}

output "security_group_id" {
  value = aws_security_group.idc-singa.id
  depends_on = [ aws_security_group.idc-singa ]
}