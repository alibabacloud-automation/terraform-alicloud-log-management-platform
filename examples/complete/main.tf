provider "alicloud" {
  region = var.region
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = false
  special = false
}

module "log_management_platform" {
  source = "../../"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
    vpc_name   = "log-platform-vpc-${random_string.suffix.id}"
  }

  vswitch_config = {
    cidr_block   = "192.168.0.0/24"
    zone_id      = data.alicloud_zones.default.zones[0].id
    vswitch_name = "log-platform-vswitch-${random_string.suffix.id}"
  }

  security_group_config = {
    security_group_name = "log-collection-sg-${random_string.suffix.id}"
  }

  security_group_kibana_config = {
    security_group_name = "kibana-sg-${random_string.suffix.id}"
  }

  ram_user_config = {
    name = "log-platform-user-${random_string.suffix.id}"
  }

  instance_config = {
    instance_name              = "log-collection-instance-${random_string.suffix.id}"
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = var.instance_type
    system_disk_category       = "cloud_essd"
    password                   = var.ecs_instance_password
    internet_max_bandwidth_out = 5
  }

  instance_kibana_config = {
    instance_name              = "kibana-instance-${random_string.suffix.id}"
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = var.instance_type_xlarge
    system_disk_category       = "cloud_essd"
    password                   = var.ecs_instance_password
    internet_max_bandwidth_out = 10
  }

  log_project_config = {
    project_name = "log-project-${random_string.suffix.id}"
    description  = "Log management platform project"
  }

  log_store_config = {
    logstore_name = "log-store-${random_string.suffix.id}"
  }

  log_machine_group_config = {
    name          = "log-machine-group-${random_string.suffix.id}"
    identify_type = "ip"
  }

  logtail_config_config = {
    name = "logtail-config-${random_string.suffix.id}"
    input_detail = jsonencode({
      discardUnmatch = false
      enableRawLog   = true
      fileEncoding   = "utf8"
      filePattern    = "sls-monitor-test.log"
      logPath        = "/tmp"
      logType        = "common_reg_log"
      maxDepth       = 10
      topicFormat    = "none"
    })
    input_type  = "file"
    output_type = "LogService"
  }

  log_store_index_config = {
    full_text_token    = " :#$^*\\r\\n\\t"
    field_search_name  = "content"
    field_search_type  = "text"
    field_search_token = " :#$^*\\r\\n\\t"
  }

  security_group_rules_config = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      nic_type    = "intranet"
      policy      = "accept"
      port_range  = "5601/5601"
      priority    = 1
      cidr_ip     = "192.168.0.0/24"
    }
  ]

  ram_policy_attachment_config = {
    policy_type = "System"
    policy_name = "AliyunLogFullAccess"
  }

  ecs_command_config = {
    name        = "command-genlog-loongcollector-${random_string.suffix.id}"
    working_dir = "/root"
    type        = "RunShellScript"
    timeout     = 3600
  }

  ecs_command_kibana_config = {
    name        = "command-kibana-${random_string.suffix.id}"
    working_dir = "/root"
    type        = "RunShellScript"
    timeout     = 3600
  }
}