output "vpc_id" {
  value = aws_vpc.idc-seoul.id
}
output "subnet_id" {
  value = aws_subnet.idc-seoul.id
}
output "route_table_id" {
  value = aws_route_table.idc-seoul.id
  depends_on = [ aws_route_table.idc-seoul ]
}
output "cgw_route_table_id" {
  value = aws_route_table.idc-cgw.id
  depends_on = [ aws_route_table.idc-cgw ]
}
output "cgw_subnet_id" {
  value = aws_subnet.idc-cgw.id
  depends_on = [ aws_subnet.idc-cgw ]
  
}
output "security_group_id" {
  value = aws_security_group.idc-seoul.id
  depends_on = [ aws_security_group.idc-seoul ]
}