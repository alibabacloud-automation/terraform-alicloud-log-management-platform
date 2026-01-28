variable "vpc_config" {
  description = "VPC configuration parameters. The attribute 'cidr_block' is required."
  type = object({
    cidr_block = string
    vpc_name   = string
  })
}

variable "vswitch_config" {
  description = "VSwitch configuration parameters. The attributes 'cidr_block' and 'zone_id' are required."
  type = object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = string
  })
}

variable "security_group_config" {
  description = "Security group configuration parameters for log collection ECS instance."
  type = object({
    security_group_name = string
  })
  default = {
    security_group_name = "log-collection-sg"
  }
}

variable "security_group_kibana_config" {
  description = "Security group configuration parameters for Kibana ECS instance."
  type = object({
    security_group_name = string
  })
  default = {
    security_group_name = "kibana-sg"
  }
}

variable "security_group_rules_config" {
  description = "List of security group rule configuration parameters for Kibana and other service access."
  type = list(object({
    type        = string
    ip_protocol = string
    nic_type    = string
    policy      = string
    port_range  = string
    priority    = number
    cidr_ip     = string
  }))
  default = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "5601/5601"
      priority    = 1
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}

variable "ram_user_config" {
  description = "RAM user configuration parameters."
  type = object({
    name = string
  })
}

variable "ram_policy_attachment_config" {
  description = "RAM policy attachment configuration parameters."
  type = object({
    policy_type = string
    policy_name = string
  })
  default = {
    policy_type = "System"
    policy_name = "AliyunLogFullAccess"
  }
}

variable "instance_config" {
  description = "ECS instance configuration parameters for log collection. The attributes 'image_id', 'instance_type', 'system_disk_category', 'password', 'internet_max_bandwidth_out' are required."
  type = object({
    instance_name              = string
    image_id                   = string
    instance_type              = string
    system_disk_category       = string
    password                   = string
    internet_max_bandwidth_out = number
  })
}

variable "instance_kibana_config" {
  description = "ECS instance configuration parameters for Kibana. The attributes 'image_id', 'instance_type', 'system_disk_category', 'password', 'internet_max_bandwidth_out' are required."
  type = object({
    instance_name              = string
    image_id                   = string
    instance_type              = string
    system_disk_category       = string
    password                   = string
    internet_max_bandwidth_out = number
  })
}

variable "log_project_config" {
  description = "SLS log project configuration parameters."
  type = object({
    project_name = string
    description  = string
  })
  default = {
    project_name = "sls-project"
    description  = "Log management platform project"
  }
}

variable "log_store_config" {
  description = "SLS log store configuration parameters."
  type = object({
    logstore_name = string
  })
  default = {
    logstore_name = "sls-logstore"
  }
}

variable "log_machine_group_config" {
  description = "Log machine group configuration parameters."
  type = object({
    name          = string
    identify_type = string
  })
  default = {
    name          = "lmg"
    identify_type = "ip"
  }
}

variable "logtail_config_config" {
  description = "Logtail configuration parameters."
  type = object({
    name         = string
    input_detail = string
    input_type   = string
    output_type  = string
  })
  default = {
    name         = "lc"
    input_detail = <<EOF
{
  "discardUnmatch": false,
  "enableRawLog": true,
  "fileEncoding": "utf8",
  "filePattern": "sls-monitor-test.log",
  "logPath": "/tmp",
  "logType": "common_reg_log",
  "maxDepth": 10,
  "topicFormat": "none"
}
EOF
    input_type   = "file"
    output_type  = "LogService"
  }
}

variable "log_store_index_config" {
  description = "Log store index configuration parameters."
  type = object({
    full_text_token    = string
    field_search_name  = string
    field_search_type  = string
    field_search_token = string
  })
  default = {
    full_text_token    = " :#$^*\\r\\n\\t"
    field_search_name  = "content"
    field_search_type  = "text"
    field_search_token = " :#$^*\\r\\n\\t"
  }
}

variable "ecs_command_config" {
  description = "ECS command configuration parameters for log collection setup."
  type = object({
    name        = string
    working_dir = string
    type        = string
    timeout     = number
  })
  default = {
    name        = "command-genlog-loongcollector"
    working_dir = "/root"
    type        = "RunShellScript"
    timeout     = 3600
  }
}

variable "ecs_command_kibana_config" {
  description = "ECS command configuration parameters for Kibana setup."
  type = object({
    name        = string
    working_dir = string
    type        = string
    timeout     = number
  })
  default = {
    name        = "command-kibana"
    working_dir = "/root"
    type        = "RunShellScript"
    timeout     = 3600
  }
}

variable "custom_log_collection_script" {
  description = "Custom log collection script for ECS instance initialization. If not provided, the default script will be used."
  type        = string
  default     = null
}

variable "custom_kibana_setup_script" {
  description = "Custom Kibana setup script for ECS instance initialization. If not provided, the default script will be used."
  type        = string
  default     = null
}

variable "elasticsearch_password" {
  description = "Password for Elasticsearch/Kibana authentication."
  type        = string
  default     = "DefaultPass123!"
}

variable "invocation_timeout_create" {
  description = "Timeout duration for ECS invocation creation operations."
  type        = string
  default     = "60m"
}