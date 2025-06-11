locals {
  prefix             = "${var.prefix}-"
  config_file_script = var.config_file != "" ? file(var.config_file) : ""
  config_script      = var.config_script != "" ? "${var.config_script}\n${local.config_file_script}" : local.config_file_script
  interfaces_need_lb = {
    for ni in var.network_interfaces : ni.network_name => ni
    if ni.internal_lb != null
  }
  nic_list = [
    for ni in var.network_interfaces : merge({
      subnet_name   = ni.subnet_name
      has_public_ip = ni.has_public_ip
      ilb_ip        = lookup(local.interfaces_need_lb, ni.network_name, null) != null ? google_compute_address.ilb_ip[ni.network_name].address : ""
      elb_ip        = ""
      },
      ni.additional_variables != null ? ni.additional_variables : {}
    )
  ]
  func_port_index = tonumber(regex("port(\\d+)", var.cloud_function.cloud_func_interface)[0]) - 1
}

# FGT instance
module "fortigate_asg" {
  source = "../../modules/fortigate/fgt_asg_with_function"

  prefix                = var.prefix
  service_account_email = var.service_account_email
  hostname              = var.fgt_hostname
  fgt_password          = var.fgt_password
  project               = var.project
  zone                  = var.zone
  zones                 = var.zones
  region                = var.region
  machine_type          = var.machine_type
  image_type            = var.image_type
  image_source          = var.image_source

  network_interfaces = local.nic_list
  additional_disk    = var.additional_disk
  config_script      = local.config_script
  network_tags       = var.network_tags
  cloud_function = {
    vpc_network                   = var.network_interfaces[local.func_port_index].network_name
    function_ip_range             = var.cloud_function.function_ip_range
    license_source                = var.cloud_function.license_source
    license_file_folder           = var.cloud_function.license_file_folder
    autoscale_psksecret           = var.cloud_function.autoscale_psksecret
    logging_level                 = var.cloud_function.logging_level
    fortiflex                     = var.cloud_function.fortiflex
    service_config                = var.cloud_function.service_config
    build_service_account_email   = var.cloud_function.build_service_account_email
    trigger_service_account_email = var.cloud_function.trigger_service_account_email
    additional_variables = merge(var.cloud_function.additional_variables,
      {
        HA_SYNC_INTERFACE    = var.ha_sync_interface
        CLOUD_FUNC_INTERFACE = var.cloud_function.cloud_func_interface
        HEALTHCHECK_PORT     = var.autoscaler.autohealing.health_check_port
      }
    )
  }
  bucket           = var.bucket
  autoscaler       = var.autoscaler
  fmg_integration  = var.fmg_integration
  special_behavior = var.special_behavior
  depends_on = [
    google_compute_address.ilb_ip
  ]
}

# This health check is for load balancer.
resource "google_compute_region_health_check" "hc" {
  count              = length(local.interfaces_need_lb) > 0 ? 1 : 0
  name               = "${local.prefix}lb-hc"
  region             = var.region
  timeout_sec        = 5
  check_interval_sec = 5
  tcp_health_check {
    port = var.autoscaler.autohealing.health_check_port
  }
}

resource "google_compute_address" "ilb_ip" {
  for_each     = local.interfaces_need_lb
  name         = "${local.prefix}ilb-ip-${each.value.subnet_name}"
  address      = each.value.internal_lb.front_end_ip == "" ? null : each.value.internal_lb.front_end_ip
  address_type = "INTERNAL"
  subnetwork   = each.value.subnet_name
}

module "internal_lb" {
  for_each          = local.interfaces_need_lb
  source            = "../../modules/gcp/lb"
  prefix            = "${local.prefix}ilb-${each.value.subnet_name}"
  region            = var.region
  schema            = "INTERNAL"
  front_end_ip      = google_compute_address.ilb_ip[each.key].address
  frontend_protocol = each.value.internal_lb.frontend_protocol
  backend_protocol  = each.value.internal_lb.backend_protocol
  ilb = {
    network_id = each.value.network_name
    subnet_id  = each.value.subnet_name
  }
  health_check = {
    use_existing_health_check = true
    existing_self_link        = google_compute_region_health_check.hc[0].self_link
  }
  backends_list = [module.fortigate_asg.instance_group_id]
  use_all_ports = true
}

resource "google_compute_route" "default_route" {
  for_each = {
    for network_name, ni in local.interfaces_need_lb : network_name => ni
    if ni.internal_lb.ip_range_route_to_lb != ""
  }
  name         = "${local.prefix}route-${each.value.network_name}"
  dest_range   = each.value.internal_lb.ip_range_route_to_lb
  network      = each.value.network_name
  next_hop_ilb = module.internal_lb[each.key].lb.self_link
  priority     = 100
}
