variable "vpc_id" {
    type = string
    description = "require vpc id"
}

variable "igw_name" {
    type = string
    default = "igw"
}

variable "route_table_id" {
    type = string
    description = "require route table id"
}

variable "destination_cidr_block" {
    type = string
    default = "0.0.0.0/0"
}
