locals {
  prefix             = "${var.prefix}-"
  config_file_script = var.config_file != "" ? file(var.config_file) : ""
  config_script      = var.config_script != "" ? "${var.config_script}\n${local.config_file_script}" : local.config_file_script
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

  network_interfaces = [
    {
      subnet_name   = "${local.prefix}external"
      has_public_ip = var.fgt_has_public_ip
      elb_ip        = google_compute_address.elb_ip.address
    },
    {
      subnet_name = "${local.prefix}internal"
      ilb_ip      = google_compute_address.ilb_ip.address
    },
  ]
  additional_disk = var.additional_disk
  config_script   = local.config_script
  network_tags    = ["external-access", "internal-access"]
  cloud_function = {
    vpc_network          = module.vpc_external.network.self_link
    function_ip_range    = var.cloud_function.function_ip_range
    license_source       = var.cloud_function.license_source
    license_file_folder  = var.cloud_function.license_file_folder
    autoscale_psksecret  = var.cloud_function.autoscale_psksecret
    logging_level        = var.cloud_function.logging_level
    fortiflex            = var.cloud_function.fortiflex
    service_config       = var.cloud_function.service_config
    additional_variables = var.cloud_function.additional_variables
  }
  autoscaler = var.autoscaler
  depends_on = [module.vpc_external, module.vpc_internal]
}

resource "google_compute_address" "elb_ip" {
  name         = "${local.prefix}elb-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "ilb_ip" {
  name         = "${local.prefix}ilb-ip"
  address      = var.load_balancer.internal_lb.front_end_ip == "" ? null : var.load_balancer.internal_lb.front_end_ip
  address_type = "INTERNAL"
  subnetwork   = module.vpc_internal.subnets["${local.prefix}internal"].id
}

module "internal_lb" {
  source            = "../../modules/gcp/lb"
  prefix            = "${local.prefix}ilb"
  region            = var.region
  schema            = "INTERNAL"
  front_end_ip      = google_compute_address.ilb_ip.address
  frontend_protocol = var.load_balancer.internal_lb.frontend_protocol
  backend_protocol  = var.load_balancer.internal_lb.backend_protocol
  ilb = {
    network_id = module.vpc_internal.network.self_link
    subnet_id  = module.vpc_internal.subnets["${local.prefix}internal"].self_link
  }
  health_check = {
    port = var.load_balancer.health_check_port
  }
  backends_list = [module.fortigate_asg.instance_group_id]
  use_all_ports = true
}

module "external_lb" {
  source       = "../../modules/gcp/lb"
  prefix       = "${local.prefix}elb"
  region       = var.region
  schema       = "EXTERNAL"
  front_end_ip = google_compute_address.elb_ip.address
  health_check = {
    use_existing_health_check = true
    existing_self_link        = module.internal_lb.health_check_self_link
  }
  frontend_protocol = var.load_balancer.external_lb.frontend_protocol
  backend_protocol  = var.load_balancer.external_lb.backend_protocol
  backends_list     = [module.fortigate_asg.instance_group_id]
  use_all_ports     = true
}
