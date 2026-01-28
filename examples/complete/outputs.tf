output "ecs_login_address" {
  description = "The login address for the log collection ECS instance. Use this address to log in to the ECS instance and view generated log files with command: tail -f /tmp/sls-monitor-test.log"
  value       = module.log_management_platform.ecs_login_address
}

output "sls_logsearch_url" {
  description = "The SLS log search console URL"
  value       = module.log_management_platform.sls_logsearch_url
}

output "kibana_management_url" {
  description = "The Kibana management console URL. Login with username 'elastic' and the password you configured"
  value       = module.log_management_platform.kibana_management_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.log_management_platform.vpc_id
}

output "log_project_name" {
  description = "The name of the SLS log project"
  value       = module.log_management_platform.log_project_name
}

output "log_store_name" {
  description = "The name of the SLS log store"
  value       = module.log_management_platform.log_store_name
}