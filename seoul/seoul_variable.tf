provider "aws" {
  alias = "seoul"
  region = "ap-northeast-2"
}


# key pair
variable "seoulkey" {
  description = "Seoul Key pair name"
  type = string
  default = "soldesk-key"
}

# ami
variable "seoul-nat-ami" {
  type = string
  default = "ami-0c2d3e23e757b5d84"
}
variable "seoul-ami" {
  type = string
  default = "ami-04c535bac3bf07b9a"
}


