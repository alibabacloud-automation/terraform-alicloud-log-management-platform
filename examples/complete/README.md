# Complete Example

This example demonstrates how to deploy a complete large-scale, low-cost, real-time log management platform using the log management platform module.

## Architecture

The example creates:

- A VPC and VSwitch for network isolation
- Two ECS instances: one for log collection with LoongCollector, one for Kibana
- SLS (Simple Log Service) project and log store for centralized log storage
- RAM user with appropriate permissions for SLS access
- Security groups and rules for proper network access
- Logtail configuration for log collection
- Kibana deployment via Docker for log visualization

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (ECS instances, for example). Run `terraform destroy` when you don't need these resources.

## Notes

- The ECS instance password must be 8-30 characters long and contain at least three types of characters: uppercase letters, lowercase letters, numbers, and special characters.
- After deployment, it may take a few minutes for the LoongCollector and Kibana services to be fully initialized.
- Log files are generated automatically and can be viewed at `/tmp/sls-monitor-test.log` on the log collection ECS instance.
- Kibana will be accessible on port 5601 of the Kibana ECS instance's public IP address.

## Clean Up

To destroy the resources:

```bash
terraform destroy
```