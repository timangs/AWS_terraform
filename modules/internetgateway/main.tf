resource "aws_internet_gateway" "this" {
    provider = aws
    vpc_id = var.vpc_id
    tags = {
        Name = var.igw_name
    }
}

resource "aws_route" "this" {
    provider = aws
    route_table_id            = var.route_table_id
    destination_cidr_block    = var.destination_cidr_block
    gateway_id = aws_internet_gateway.this.id
}