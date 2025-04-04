variable "vpc_id" {
  default = "vpc-026b5dfaf17f6bbb4"
  type = string
  description = "totoro"
}

variable "h" {
  default = "log-"
  type = string
}

variable "elastic_url" {
  default = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:ela"
  type = string
}

variable "logstash_url" {
  default = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:log"
  type = string
}

variable "kibana_url" {
  default = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:kib"
  type = string
}

variable "use_existing_igw" {
  description = "기존 인터넷 게이트웨이를 사용할 경우 true"
  type        = bool
  default     = true 
}
