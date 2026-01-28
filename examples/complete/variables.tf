variable "region" {
  type        = string
  description = "The Alibaba Cloud region to deploy resources in"
  default     = "cn-zhangjiakou"
}

variable "instance_type" {
  type        = string
  description = "The ECS instance type for log collection"
  default     = "ecs.e-c1m2.large"
}

variable "instance_type_xlarge" {
  type        = string
  description = "The ECS instance type for Kibana (higher performance)"
  default     = "ecs.e-c1m2.xlarge"
}

variable "ecs_instance_password" {
  type        = string
  description = "The password for ECS instances. Must be 8-30 characters long and contain at least three types of characters: uppercase letters, lowercase letters, numbers, and special characters from ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/"
  sensitive   = true
}