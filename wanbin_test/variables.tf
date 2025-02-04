provider "aws" {
  alias = "seoul"
  region = "ap-northeast-2"
}
provider "aws" {
  alias = "sp"
  region = "ap-southeast-1"
}
variable "seoul_key_name" {
  description = "Name of an existing EC2 KeyPair"
  type = string
  default = "temp"
}
variable "sp_key_name" {
  description = "Name of an existing EC2 KeyPair"
  type = string
  default = "sptemp"
}
variable "seoul_nat_image_id" {
  description = "NATImageId Value"
  type        = string
  default     = "ami-01ad0c7a4930f0e43"
}
variable "sp_nat_image_id" {
  description = "NATImageId Value"
  type        = string
  default     = "ami-00004f35d3112b57b"
}
variable "region_image_id" {
  description = "RegionImageId Value"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
variable "instance_type" {
  description = "Instance t2.micro"
  type        = string
  default     = "t2.micro"
}