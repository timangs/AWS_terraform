provider "aws" {
  alias = "si"
  region = "ap-southeast-1"
}

provider "aws" {
  alias = "se"
  region = "ap-northeast-2"
}


# key pair
variable "se_key" {
  description = "Seoul Key pair name"
  type = string
  default = "Instance-key"
}
variable "si_key" {
  description = "singapore Key pair name"
  type = string
  default = "Instance-key-si"
}

# ami
variable "se_nat_ami" {
  type = string
  default = "ami-0c2d3e23e757b5d84"
}
variable "se_ami" {
  type = string
  default = "ami-04c535bac3bf07b9a"
}
variable "si_nat_ami" {
  type = string
  default = "ami-097c9351ea0aa8d71"
}
variable "si_ami" {
  type = string
  default = "ami-0de20ddce8ba98c24"
}
variable "se_datasync_ami" {
  type = string
  default = "ami-001e5d98f36954fe6"
}

variable "instance_type" {
  description = "Instance t2.micro"
  type        = string
  default     = "t2.micro"
}

variable "datasync_instance_type" {
  description = "Instance m5.2xlarge"
  default = "m5.2xlarge"
}