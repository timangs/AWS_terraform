variable "name" {
  type        = string
  default = "lb"
}

variable "internal" {
  type        = bool
  default = false
}

variable "load_balancer_type" {
  type        = string
  default = "application"
}

variable "security_groups" {
  type        = list(string)
  description = "require security group id"
}

variable "subnets" {
  type        = list(string)
  description = "require subnet id list"
}

variable "enable_deletion_protection" {
  type        = bool
  default = false
}

variable "target_group_name" {
  type        = string
  default = "tg"
}

variable "target_group_port" {
  type        = number
  default = 80
}

variable "target_group_protocol" {
  type        = string
  default = "HTTP"
}

variable "vpc_id" {
  type        = string
    description = "require vpc id"
}

variable "health_check_healthy_threshold" {
  type        = number
  default = 3
}

variable "health_check_unhealthy_threshold" {
  type        = number
  default = 3
}

variable "health_check_timeout" {
  type        = number
  default = 5
}

variable "health_check_interval" {
  type        = number
  default = 30
}

variable "health_check_path" {
  type        = string
  default = "/"
}

variable "health_check_matcher" {
  type        = string
  default = "200"
}

variable "listener_port" {
  type        = number
  default = 80
}

variable "listener_protocol" {
  type        = string
  default = "HTTP"
}

variable "target_id" {
  type        = list(string)
    description = "require target instance id list"
}
