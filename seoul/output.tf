# transitgateway between each region
output "subnet1_id" {
  value = aws_subnet.seoul["sn1"].id
}
output "subnet2_id" {
  value = aws_subnet.seoul["sn2"].id
}
output "vpc_id" {
  value = aws_vpc.seoul.id
}

# route for transit gateway
output "rt_id" {
  value = aws_route_table.seoul["public"].id
  
}