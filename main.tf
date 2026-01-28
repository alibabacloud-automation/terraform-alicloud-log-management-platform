data "alicloud_regions" "current" {
  current = true
}

# Create VPC for the log management platform
resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_config.cidr_block
  vpc_name   = var.vpc_config.vpc_name
}

# Create VSwitch for the VPC
resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_config.cidr_block
  zone_id      = var.vswitch_config.zone_id
  vswitch_name = var.vswitch_config.vswitch_name
}

# Create security group for log collection ECS instance
resource "alicloud_security_group" "security_group" {
  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = var.security_group_config.security_group_name
}

# Create security group for Kibana ECS instance
resource "alicloud_security_group" "security_group_kibana" {
  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = var.security_group_kibana_config.security_group_name
}

# Create security group rules to allow Kibana access
resource "alicloud_security_group_rule" "allow_kibana" {
  for_each          = { for i, rule in var.security_group_rules_config : i => rule }
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  security_group_id = alicloud_security_group.security_group_kibana.id
  cidr_ip           = each.value.cidr_ip
}

# Create RAM user for SLS access
resource "alicloud_ram_user" "ram_user" {
  name = var.ram_user_config.name
}

# Create RAM access key for the user
resource "alicloud_ram_access_key" "ramak" {
  user_name = alicloud_ram_user.ram_user.name
}

# Attach policy to RAM user
resource "alicloud_ram_user_policy_attachment" "attach_policy_to_user" {
  user_name   = alicloud_ram_user.ram_user.name
  policy_type = var.ram_policy_attachment_config.policy_type
  policy_name = var.ram_policy_attachment_config.policy_name
}

# Create SLS project
resource "alicloud_log_project" "sls_project" {
  project_name = var.log_project_config.project_name
  description  = var.log_project_config.description
}

# Create SLS log store
resource "alicloud_log_store" "sls_log_store" {
  logstore_name = var.log_store_config.logstore_name
  project_name  = alicloud_log_project.sls_project.project_name
}

# Create log machine group
resource "alicloud_log_machine_group" "machine_group" {
  identify_list = [alicloud_instance.ecs_instance.primary_ip_address]
  name          = var.log_machine_group_config.name
  project       = alicloud_log_project.sls_project.project_name
  identify_type = var.log_machine_group_config.identify_type
}

# Create logtail configuration
resource "alicloud_logtail_config" "logtail_config" {
  project      = alicloud_log_project.sls_project.project_name
  input_detail = var.logtail_config_config.input_detail
  input_type   = var.logtail_config_config.input_type
  logstore     = alicloud_log_store.sls_log_store.logstore_name
  name         = var.logtail_config_config.name
  output_type  = var.logtail_config_config.output_type
}

# Attach logtail configuration to machine group
resource "alicloud_logtail_attachment" "logtail_attachment" {
  project             = alicloud_log_project.sls_project.project_name
  logtail_config_name = alicloud_logtail_config.logtail_config.name
  machine_group_name  = alicloud_log_machine_group.machine_group.name
}

# Create log store index
resource "alicloud_log_store_index" "sls_index" {
  project  = alicloud_log_project.sls_project.project_name
  logstore = alicloud_log_store.sls_log_store.logstore_name
  full_text {
    token = var.log_store_index_config.full_text_token
  }
  field_search {
    name  = var.log_store_index_config.field_search_name
    type  = var.log_store_index_config.field_search_type
    token = var.log_store_index_config.field_search_token
  }
}

# Create ECS instance for log generation and LoongCollector
resource "alicloud_instance" "ecs_instance" {
  instance_name              = var.instance_config.instance_name
  image_id                   = var.instance_config.image_id
  instance_type              = var.instance_config.instance_type
  system_disk_category       = var.instance_config.system_disk_category
  security_groups            = [alicloud_security_group.security_group.id]
  vswitch_id                 = alicloud_vswitch.vswitch.id
  password                   = var.instance_config.password
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
  depends_on                 = [alicloud_log_store_index.sls_index]
}

# Create ECS instance for Kibana deployment
resource "alicloud_instance" "ecs_instance_kibana" {
  instance_name              = var.instance_kibana_config.instance_name
  image_id                   = var.instance_kibana_config.image_id
  instance_type              = var.instance_kibana_config.instance_type
  system_disk_category       = var.instance_kibana_config.system_disk_category
  security_groups            = [alicloud_security_group.security_group_kibana.id]
  vswitch_id                 = alicloud_vswitch.vswitch.id
  password                   = var.instance_kibana_config.password
  internet_max_bandwidth_out = var.instance_kibana_config.internet_max_bandwidth_out
}

# Define default scripts in locals
locals {
  default_log_collection_script = <<-EOF
    cat << EOT >> ~/.bash_profile
    export ROS_DEPLOY=true
    export ALIBABA_CLOUD_ACCESS_KEY_ID=${alicloud_ram_access_key.ramak.id}
    export ALIBABA_CLOUD_ACCESS_KEY_SECRET=${alicloud_ram_access_key.ramak.secret}
    EOT

    source ~/.bash_profile
    sleep 60
    # Install loongcollector
    wget http://aliyun-observability-release-${data.alicloud_regions.current.regions[0].id}.oss-${data.alicloud_regions.current.regions[0].id}.aliyuncs.com/loongcollector/linux64/latest/loongcollector.sh -O loongcollector.sh
    chmod +x loongcollector.sh
    ./loongcollector.sh install ${data.alicloud_regions.current.regions[0].id}-internet
    # Generate log
    curl -fsSL https://help-static-aliyun-doc.aliyuncs.com/tech-solution/install-log-monitoring-alarming-0.1.sh|bash
  EOF

  default_kibana_setup_script = <<-EOF
    cat << EOT >> ~/.bash_profile
    export ROS_DEPLOY=true
    export ALIBABA_CLOUD_ACCESS_KEY_ID=${alicloud_ram_access_key.ramak.id}
    export ALIBABA_CLOUD_ACCESS_KEY_SECRET=${alicloud_ram_access_key.ramak.secret}
    EOT

    source ~/.bash_profile

    # Install Docker
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum -y install docker-ce
    docker --version
    systemctl start docker
    systemctl enable docker

    # Create project directory and data directory
    mkdir sls-kibana
    cd sls-kibana
    mkdir data
    chmod 777 data

    # Create .env file
    cat << EOJ >> .env
    ES_PASSWORD=${alicloud_instance.ecs_instance_kibana.password}
    SLS_ENDPOINT=${data.alicloud_regions.current.regions[0].id}.log.aliyuncs.com
    SLS_PROJECT=${alicloud_log_project.sls_project.project_name}
    SLS_ACCESS_KEY_ID=${alicloud_ram_access_key.ramak.id}
    SLS_ACCESS_KEY_SECRET=${alicloud_ram_access_key.ramak.secret}
    EOJ

    # Create docker-compose.yaml file
    cat << EOK >> docker-compose.yaml
    services:
      es:
        image: sls-registry.cn-hangzhou.cr.aliyuncs.com/kproxy/elasticsearch:7.17.26
        environment:
          - "discovery.type=single-node"
          - "ES_JAVA_OPTS=-Xms2G -Xmx2G"
          - ELASTIC_USERNAME=elastic
          - ELASTIC_PASSWORD=${alicloud_instance.ecs_instance_kibana.password}
          - xpack.security.enabled=true
        volumes:
          - ./data:/usr/share/elasticsearch/data
      kproxy:
        image: sls-registry.cn-hangzhou.cr.aliyuncs.com/kproxy/kproxy:2.1.4
        depends_on:
          - es
        environment:
          - ES_ENDPOINT=es:9200
          - SLS_ENDPOINT=${data.alicloud_regions.current.regions[0].id}.log.aliyuncs.com
          - SLS_PROJECT=${alicloud_log_project.sls_project.project_name}
          - SLS_ACCESS_KEY_ID=${alicloud_ram_access_key.ramak.id}
          - SLS_ACCESS_KEY_SECRET=${alicloud_ram_access_key.ramak.secret}
      kibana:
        image: sls-registry.cn-hangzhou.cr.aliyuncs.com/kproxy/kibana:7.17.26
        depends_on:
          - kproxy
        environment:
          - ELASTICSEARCH_HOSTS=http://kproxy:9201
          - ELASTICSEARCH_USERNAME=elastic
          - ELASTICSEARCH_PASSWORD=${alicloud_instance.ecs_instance_kibana.password}
          - XPACK_MONITORING_UI_CONTAINER_ELASTICSEARCH_ENABLED=true
        ports:
          - "5601:5601"
      index-patterner:
        image: sls-registry.cn-hangzhou.cr.aliyuncs.com/kproxy/kproxy:2.1.4
        command: /usr/bin/python3 -u /workspace/create_index_pattern.py
        depends_on:
          - kibana
        environment:
          - KPROXY_ENDPOINT=http://kproxy:9201
          - KIBANA_ENDPOINT=http://kibana:5601
          - KIBANA_USER=elastic
          - KIBANA_PASSWORD=${alicloud_instance.ecs_instance_kibana.password}
          - SLS_ACCESS_KEY_ID=${alicloud_ram_access_key.ramak.id}
          - SLS_ACCESS_KEY_SECRET=${alicloud_ram_access_key.ramak.secret}
    EOK

    # Start Kibana services
    docker compose up -d
    docker compose ps
  EOF
}

# Create ECS command for log collection and LoongCollector setup
resource "alicloud_ecs_command" "run_command" {
  name            = var.ecs_command_config.name
  command_content = base64encode(var.custom_log_collection_script != null ? var.custom_log_collection_script : local.default_log_collection_script)
  working_dir     = var.ecs_command_config.working_dir
  type            = var.ecs_command_config.type
  timeout         = var.ecs_command_config.timeout
}

# Create ECS command for Kibana setup
resource "alicloud_ecs_command" "run_command_kibana" {
  name            = var.ecs_command_kibana_config.name
  command_content = base64encode(var.custom_kibana_setup_script != null ? var.custom_kibana_setup_script : local.default_kibana_setup_script)
  working_dir     = var.ecs_command_kibana_config.working_dir
  type            = var.ecs_command_kibana_config.type
  timeout         = var.ecs_command_kibana_config.timeout
}

# Execute command on log collection ECS instance
resource "alicloud_ecs_invocation" "invoke_script" {
  instance_id = [alicloud_instance.ecs_instance.id]
  command_id  = alicloud_ecs_command.run_command.id
  timeouts {
    create = var.invocation_timeout_create
  }
}

# Execute command on Kibana ECS instance
resource "alicloud_ecs_invocation" "invoke_script_kibana" {
  instance_id = [alicloud_instance.ecs_instance_kibana.id]
  command_id  = alicloud_ecs_command.run_command_kibana.id
  timeouts {
    create = var.invocation_timeout_create
  }
}