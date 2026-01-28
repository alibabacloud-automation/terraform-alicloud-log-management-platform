用于阿里云的大规模低成本实时日志管理平台 Terraform 模块

# terraform-alicloud-log-management-platform


[English](https://github.com/alibabacloud-automation/terraform-alicloud-log-management-platform/blob/main/README.md) | 简体中文

这个 Terraform 模块在阿里云上创建一个综合的日志管理平台，使用 SLS（简单日志服务）、ECS 实例和 Kibana 进行可视化。该模块实现了一个经济高效、可扩展的实时日志收集、处理和分析解决方案。本模块用于实现解决方案[开源自建ELK上云指南：基于阿里云日志服务（SLS）构建低成本可扩展日志平台](https://www.aliyun.com/solution/tech-solution/build-large-scale-low-cost-real-time-log-management-platform)，涉及到专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、RAM 用户等资源的创建。

## 使用方法

```hcl
provider "alicloud" {
  region = "cn-hangzhou"
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

module "log_management_platform" {
  source = "alibabacloud-automation/log-management-platform/alicloud"
  
  # 必需变量
  availability_zone    = data.alicloud_zones.default.zones[0].id
  ecs_image_id        = data.alicloud_images.default.images[0].id
  ecs_instance_password = "YourSecurePassword123!"
  
  # 可选变量
  common_name                = "my-log-platform"
  vpc_cidr_block            = "192.168.0.0/16"
  vswitch_cidr_block        = "192.168.0.0/24"
  ecs_instance_type         = "ecs.e-c1m2.large"
  kibana_instance_type      = "ecs.e-c1m2.xlarge"
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-log-management-platform/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | 1.269.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_ecs_command.run_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_command.run_command_kibana](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.invoke_script](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_ecs_invocation.invoke_script_kibana](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.ecs_instance](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_instance.ecs_instance_kibana](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_log_machine_group.machine_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_machine_group) | resource |
| [alicloud_log_project.sls_project](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_project) | resource |
| [alicloud_log_store.sls_log_store](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource |
| [alicloud_log_store_index.sls_index](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store_index) | resource |
| [alicloud_logtail_attachment.logtail_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/logtail_attachment) | resource |
| [alicloud_logtail_config.logtail_config](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/logtail_config) | resource |
| [alicloud_ram_access_key.ramak](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_access_key) | resource |
| [alicloud_ram_user.ram_user](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_user) | resource |
| [alicloud_ram_user_policy_attachment.attach_policy_to_user](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_user_policy_attachment) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group.security_group_kibana](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.allow_kibana](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_kibana_setup_script"></a> [custom\_kibana\_setup\_script](#input\_custom\_kibana\_setup\_script) | Custom Kibana setup script for ECS instance initialization. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_custom_log_collection_script"></a> [custom\_log\_collection\_script](#input\_custom\_log\_collection\_script) | Custom log collection script for ECS instance initialization. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | ECS command configuration parameters for log collection setup. | <pre>object({<br>    name        = string<br>    working_dir = string<br>    type        = string<br>    timeout     = number<br>  })</pre> | <pre>{<br>  "name": "command-genlog-loongcollector",<br>  "timeout": 3600,<br>  "type": "RunShellScript",<br>  "working_dir": "/root"<br>}</pre> | no |
| <a name="input_ecs_command_kibana_config"></a> [ecs\_command\_kibana\_config](#input\_ecs\_command\_kibana\_config) | ECS command configuration parameters for Kibana setup. | <pre>object({<br>    name        = string<br>    working_dir = string<br>    type        = string<br>    timeout     = number<br>  })</pre> | <pre>{<br>  "name": "command-kibana",<br>  "timeout": 3600,<br>  "type": "RunShellScript",<br>  "working_dir": "/root"<br>}</pre> | no |
| <a name="input_elasticsearch_password"></a> [elasticsearch\_password](#input\_elasticsearch\_password) | Password for Elasticsearch/Kibana authentication. | `string` | `"DefaultPass123!"` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | ECS instance configuration parameters for log collection. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', 'password', 'internet\_max\_bandwidth\_out' are required. | <pre>object({<br>    instance_name              = string<br>    image_id                   = string<br>    instance_type              = string<br>    system_disk_category       = string<br>    password                   = string<br>    internet_max_bandwidth_out = number<br>  })</pre> | n/a | yes |
| <a name="input_instance_kibana_config"></a> [instance\_kibana\_config](#input\_instance\_kibana\_config) | ECS instance configuration parameters for Kibana. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', 'password', 'internet\_max\_bandwidth\_out' are required. | <pre>object({<br>    instance_name              = string<br>    image_id                   = string<br>    instance_type              = string<br>    system_disk_category       = string<br>    password                   = string<br>    internet_max_bandwidth_out = number<br>  })</pre> | n/a | yes |
| <a name="input_invocation_timeout_create"></a> [invocation\_timeout\_create](#input\_invocation\_timeout\_create) | Timeout duration for ECS invocation creation operations. | `string` | `"60m"` | no |
| <a name="input_log_machine_group_config"></a> [log\_machine\_group\_config](#input\_log\_machine\_group\_config) | Log machine group configuration parameters. | <pre>object({<br>    name          = string<br>    identify_type = string<br>  })</pre> | <pre>{<br>  "identify_type": "ip",<br>  "name": "lmg"<br>}</pre> | no |
| <a name="input_log_project_config"></a> [log\_project\_config](#input\_log\_project\_config) | SLS log project configuration parameters. | <pre>object({<br>    project_name = string<br>    description  = string<br>  })</pre> | <pre>{<br>  "description": "Log management platform project",<br>  "project_name": "sls-project"<br>}</pre> | no |
| <a name="input_log_store_config"></a> [log\_store\_config](#input\_log\_store\_config) | SLS log store configuration parameters. | <pre>object({<br>    logstore_name = string<br>  })</pre> | <pre>{<br>  "logstore_name": "sls-logstore"<br>}</pre> | no |
| <a name="input_log_store_index_config"></a> [log\_store\_index\_config](#input\_log\_store\_index\_config) | Log store index configuration parameters. | <pre>object({<br>    full_text_token    = string<br>    field_search_name  = string<br>    field_search_type  = string<br>    field_search_token = string<br>  })</pre> | <pre>{<br>  "field_search_name": "content",<br>  "field_search_token": " :#$^*\\r\\n\\t",<br>  "field_search_type": "text",<br>  "full_text_token": " :#$^*\\r\\n\\t"<br>}</pre> | no |
| <a name="input_logtail_config_config"></a> [logtail\_config\_config](#input\_logtail\_config\_config) | Logtail configuration parameters. | <pre>object({<br>    name         = string<br>    input_detail = string<br>    input_type   = string<br>    output_type  = string<br>  })</pre> | <pre>{<br>  "input_detail": "{\n  \"discardUnmatch\": false,\n  \"enableRawLog\": true,\n  \"fileEncoding\": \"utf8\",\n  \"filePattern\": \"sls-monitor-test.log\",\n  \"logPath\": \"/tmp\",\n  \"logType\": \"common_reg_log\",\n  \"maxDepth\": 10,\n  \"topicFormat\": \"none\"\n}\n",<br>  "input_type": "file",<br>  "name": "lc",<br>  "output_type": "LogService"<br>}</pre> | no |
| <a name="input_ram_policy_attachment_config"></a> [ram\_policy\_attachment\_config](#input\_ram\_policy\_attachment\_config) | RAM policy attachment configuration parameters. | <pre>object({<br>    policy_type = string<br>    policy_name = string<br>  })</pre> | <pre>{<br>  "policy_name": "AliyunLogFullAccess",<br>  "policy_type": "System"<br>}</pre> | no |
| <a name="input_ram_user_config"></a> [ram\_user\_config](#input\_ram\_user\_config) | RAM user configuration parameters. | <pre>object({<br>    name = string<br>  })</pre> | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Security group configuration parameters for log collection ECS instance. | <pre>object({<br>    security_group_name = string<br>  })</pre> | <pre>{<br>  "security_group_name": "log-collection-sg"<br>}</pre> | no |
| <a name="input_security_group_kibana_config"></a> [security\_group\_kibana\_config](#input\_security\_group\_kibana\_config) | Security group configuration parameters for Kibana ECS instance. | <pre>object({<br>    security_group_name = string<br>  })</pre> | <pre>{<br>  "security_group_name": "kibana-sg"<br>}</pre> | no |
| <a name="input_security_group_rules_config"></a> [security\_group\_rules\_config](#input\_security\_group\_rules\_config) | List of security group rule configuration parameters for Kibana and other service access. | <pre>list(object({<br>    type        = string<br>    ip_protocol = string<br>    nic_type    = string<br>    policy      = string<br>    port_range  = string<br>    priority    = number<br>    cidr_ip     = string<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_ip": "0.0.0.0/0",<br>    "ip_protocol": "tcp",<br>    "nic_type": "intranet",<br>    "policy": "accept",<br>    "port_range": "5601/5601",<br>    "priority": 1,<br>    "type": "ingress"<br>  }<br>]</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration parameters. The attribute 'cidr\_block' is required. | <pre>object({<br>    cidr_block = string<br>    vpc_name   = string<br>  })</pre> | n/a | yes |
| <a name="input_vswitch_config"></a> [vswitch\_config](#input\_vswitch\_config) | VSwitch configuration parameters. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>object({<br>    cidr_block   = string<br>    zone_id      = string<br>    vswitch_name = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_instance_id"></a> [ecs\_instance\_id](#output\_ecs\_instance\_id) | The ID of the ECS instance for log collection |
| <a name="output_ecs_instance_kibana_id"></a> [ecs\_instance\_kibana\_id](#output\_ecs\_instance\_kibana\_id) | The ID of the ECS instance for Kibana |
| <a name="output_ecs_instance_kibana_private_ip"></a> [ecs\_instance\_kibana\_private\_ip](#output\_ecs\_instance\_kibana\_private\_ip) | The private IP address of the ECS instance for Kibana |
| <a name="output_ecs_instance_kibana_public_ip"></a> [ecs\_instance\_kibana\_public\_ip](#output\_ecs\_instance\_kibana\_public\_ip) | The public IP address of the ECS instance for Kibana |
| <a name="output_ecs_instance_private_ip"></a> [ecs\_instance\_private\_ip](#output\_ecs\_instance\_private\_ip) | The private IP address of the ECS instance for log collection |
| <a name="output_ecs_instance_public_ip"></a> [ecs\_instance\_public\_ip](#output\_ecs\_instance\_public\_ip) | The public IP address of the ECS instance for log collection |
| <a name="output_ecs_login_address"></a> [ecs\_login\_address](#output\_ecs\_login\_address) | The login address for the log collection ECS instance. Use this address to log in to the ECS instance and view generated log files with command: tail -f /tmp/sls-monitor-test.log |
| <a name="output_elasticsearch_password"></a> [elasticsearch\_password](#output\_elasticsearch\_password) | The password for Elasticsearch/Kibana authentication. |
| <a name="output_kibana_management_url"></a> [kibana\_management\_url](#output\_kibana\_management\_url) | The Kibana management console URL. Login with username 'elastic' and the password you configured |
| <a name="output_log_machine_group_name"></a> [log\_machine\_group\_name](#output\_log\_machine\_group\_name) | The name of the log machine group |
| <a name="output_log_project_name"></a> [log\_project\_name](#output\_log\_project\_name) | The name of the SLS log project |
| <a name="output_log_store_name"></a> [log\_store\_name](#output\_log\_store\_name) | The name of the SLS log store |
| <a name="output_logtail_config_name"></a> [logtail\_config\_name](#output\_logtail\_config\_name) | The name of the logtail configuration |
| <a name="output_ram_access_key_id"></a> [ram\_access\_key\_id](#output\_ram\_access\_key\_id) | The access key ID of the RAM user |
| <a name="output_ram_access_key_secret"></a> [ram\_access\_key\_secret](#output\_ram\_access\_key\_secret) | The access key secret of the RAM user |
| <a name="output_ram_user_name"></a> [ram\_user\_name](#output\_ram\_user\_name) | The name of the RAM user |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group for log collection ECS instance |
| <a name="output_security_group_kibana_id"></a> [security\_group\_kibana\_id](#output\_security\_group\_kibana\_id) | The ID of the security group for Kibana ECS instance |
| <a name="output_sls_logsearch_url"></a> [sls\_logsearch\_url](#output\_sls\_logsearch\_url) | The SLS log search console URL |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_id"></a> [vswitch\_id](#output\_vswitch\_id) | The ID of the VSwitch |
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交
[provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库上提交问题。

## 作者

由阿里云 Terraform 团队创建和维护 (terraform@alibabacloud.com)。

## 许可证

MIT 许可证。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)