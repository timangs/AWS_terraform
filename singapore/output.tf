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