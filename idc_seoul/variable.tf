provider "aws" {
  alias = "seoul"
  region = "ap-northeast-2"
}
provider "aws" {
  alias = "singapore"
  region = "ap-southeast-1"
}
# key pair
variable "seoulkey" {
  description = "Seoul Key pair name"
  type = string
  default = "soldesk-key"
}
variable "singaporekey" {
  description = "singapore Key pair name"
  type = string
  default = "soldesk-key-singapore"
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
variable "singapore-nat-ami" {
  type = string
  default = "ami-097c9351ea0aa8d71"
}
variable "singapore-ami" {
  type = string
  default = "ami-0de20ddce8ba98c24"
}


