output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = alicloud_vswitch.vswitch.id
}

output "security_group_id" {
  description = "The ID of the security group for log collection ECS instance"
  value       = alicloud_security_group.security_group.id
}

output "security_group_kibana_id" {
  description = "The ID of the security group for Kibana ECS instance"
  value       = alicloud_security_group.security_group_kibana.id
}

output "ram_user_name" {
  description = "The name of the RAM user"
  value       = alicloud_ram_user.ram_user.name
}

output "ram_access_key_id" {
  description = "The access key ID of the RAM user"
  value       = alicloud_ram_access_key.ramak.id
}

output "ram_access_key_secret" {
  description = "The access key secret of the RAM user"
  value       = alicloud_ram_access_key.ramak.secret
  sensitive   = true
}

output "ecs_instance_id" {
  description = "The ID of the ECS instance for log collection"
  value       = alicloud_instance.ecs_instance.id
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance for log collection"
  value       = alicloud_instance.ecs_instance.public_ip
}

output "ecs_instance_private_ip" {
  description = "The private IP address of the ECS instance for log collection"
  value       = alicloud_instance.ecs_instance.primary_ip_address
}

output "ecs_instance_kibana_id" {
  description = "The ID of the ECS instance for Kibana"
  value       = alicloud_instance.ecs_instance_kibana.id
}

output "ecs_instance_kibana_public_ip" {
  description = "The public IP address of the ECS instance for Kibana"
  value       = alicloud_instance.ecs_instance_kibana.public_ip
}

output "ecs_instance_kibana_private_ip" {
  description = "The private IP address of the ECS instance for Kibana"
  value       = alicloud_instance.ecs_instance_kibana.primary_ip_address
}

output "log_project_name" {
  description = "The name of the SLS log project"
  value       = alicloud_log_project.sls_project.project_name
}

output "log_store_name" {
  description = "The name of the SLS log store"
  value       = alicloud_log_store.sls_log_store.logstore_name
}

output "log_machine_group_name" {
  description = "The name of the log machine group"
  value       = alicloud_log_machine_group.machine_group.name
}

output "logtail_config_name" {
  description = "The name of the logtail configuration"
  value       = alicloud_logtail_config.logtail_config.name
}

output "ecs_login_address" {
  description = "The login address for the log collection ECS instance. Use this address to log in to the ECS instance and view generated log files with command: tail -f /tmp/sls-monitor-test.log"
  value       = format("https://ecs-workbench.aliyun.com/?from=ecs&instanceType=ecs&regionId=%s&instanceId=%s&resourceGroupId=", data.alicloud_regions.current.regions[0].id, alicloud_instance.ecs_instance.id)
}

output "sls_logsearch_url" {
  description = "The SLS log search console URL"
  value       = format("https://sls.console.aliyun.com/lognext/project/%s/logsearch/%s?slsRegion=%s", alicloud_log_project.sls_project.project_name, alicloud_log_store.sls_log_store.logstore_name, data.alicloud_regions.current.regions[0].id)
}

output "kibana_management_url" {
  description = "The Kibana management console URL. Login with username 'elastic' and the password you configured"
  value       = format("http://%s:5601", alicloud_instance.ecs_instance_kibana.public_ip)
}

output "elasticsearch_password" {
  description = "The password for Elasticsearch/Kibana authentication."
  value       = var.elasticsearch_password
  sensitive   = true
}