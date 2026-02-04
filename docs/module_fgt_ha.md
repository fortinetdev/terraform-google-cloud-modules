# Module: Deploy FGTs in HA (high availability) mode - fgt_ha

You can use this module `"fortinetdev/cloud-modules/google//modules/fortigate/fgt_ha"` to deploy two FGTs in (high availability) mode.

Currently, this module support two HA modes:

- [FGCP Active-Passive](https://docs.fortinet.com/document/fortigate/7.6.3/administration-guide/62403/fgcp)
- [FGSP Active-Active](https://docs.fortinet.com/document/fortigate/7.6.3/administration-guide/668583/fgsp)


## Template

Following example shows how to deploy two FGTs in FGCP Active-Passive mode, one external load balancer and one internal load balancer.

Create a new folder. Under this folder, create files:

**versions.tf**
```
terraform {
  required_version = ">=0.13, < 2.0.0"
  required_providers {
    google = {
      version = ">= 5.0, <8.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
```

**variable.tf**
```
variable "prefix" {
  type        = string
  description = "Prefix of all objects in this module. It should be unique to avoid name conflict between projects."
  validation {
    condition     = (can(regex("^[a-z][a-z0-9-]*$", var.prefix)) || var.prefix == "") && length(var.prefix) <= 15
    error_message = "The prefix must start with a letter, can only contain lowercase letters, numbers, and hyphens, and must not exceed 15 characters."
  }
}

variable "project" {
  type        = string
  description = "Your GCP project name."
}


variable "region" {
  type        = string
  description = "Region to deploy This project."
}


variable "zones" {
  type        = list(string)
  description = <<-EOF
  Deploy the project to multiple zones for higher availability.
  Two zone are required. If it is not specified, this module will select 2 zones for you.
  EOF  
  default     = []
}

variable "ha_mode" {
  type        = string
  default     = null
  description = <<-EOF
  HA mode of FortiGate. Options: "fgcp-ap" (FGCP active-passive) or "fgsp-aa" (FGSP active-active).
  EOF
  validation {
    condition     = can(regex("^(fgcp-ap|fgsp-aa)$", var.ha_mode))
    error_message = "The ha_mode must be either 'fgcp-ap' (FGCP active-passive) or 'fgsp-aa' (FGSP active-active)."
  }
}
```

**main.tf**
```
locals {
  prefix = "${var.prefix}-"
}

# Create 4 VPCs
module "vpcs" {
  source = "fortinetdev/cloud-modules/google//modules/gcp/vpc"
  count  = 4

  network_name = "${local.prefix}vpc${count.index + 1}-network"

  subnets = [
    {
      name          = "${local.prefix}vpc${count.index + 1}-subnet"
      region        = var.region
      ip_cidr_range = "10.${count.index}.0.0/16"
    }
  ]

  firewall_rules = [
    {
      name          = "${local.prefix}vpc${count.index + 1}-access"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["full-access"] # Network tags. All GCP instances with the tag "full-access" will follow this firewall rule.
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}

# NAT for vpc1 (port1)
resource "google_compute_router" "router" {
  name       = "${local.prefix}router"
  region     = var.region
  network    = "${local.prefix}vpc1-network"
  depends_on = [module.vpcs]
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.prefix}router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Route for vpc2 (port2)
resource "google_compute_route" "internal_to_external" {
  name         = "${local.prefix}internal-to-external"
  dest_range   = "0.0.0.0/0"
  network      = module.vpcs[1].network.self_link
  next_hop_ilb = module.internal_lb.lb.self_link
  priority     = 100
}

# External Load Balancer
resource "google_compute_address" "elb_ip" {
  name         = "${local.prefix}elb-ip"
  address_type = "EXTERNAL"
}

module "external_lb" {
  source       = "fortinetdev/cloud-modules/google//modules/gcp/lb"
  prefix       = "${local.prefix}elb"
  region       = var.region
  schema       = "EXTERNAL"
  front_end_ip = google_compute_address.elb_ip.address
  health_check = {
    use_existing_health_check = true
    existing_self_link        = module.internal_lb.health_check_self_link
  }
  frontend_protocol = "TCP"
  backend_protocol  = "TCP"
  backends_list     = module.fortigate_ha.instance_id_list
  use_all_ports     = true
  depends_on        = [module.vpcs]
}

# Internal Load Balancer in vpc2
resource "google_compute_address" "ilb_ip" {
  name         = "${local.prefix}ilb-ip"
  address      = "10.1.0.100"
  purpose      = "GCE_ENDPOINT"
  address_type = "INTERNAL"
  subnetwork   = "${local.prefix}vpc2-subnet"
  depends_on   = [module.vpcs]
}

module "internal_lb" {
  source            = "fortinetdev/cloud-modules/google//modules/gcp/lb"
  prefix            = "${local.prefix}ilb"
  region            = var.region
  schema            = "INTERNAL"
  front_end_ip      = google_compute_address.ilb_ip.address
  frontend_protocol = "TCP"
  backend_protocol  = "TCP"
  ilb = {
    network_id = module.vpcs[1].network.self_link
    subnet_id  = module.vpcs[1].subnets["${local.prefix}vpc2-subnet"].self_link
  }
  health_check = {
    port = 8008
  }
  backends_list = module.fortigate_ha.instance_id_list
  use_all_ports = true
  depends_on    = [module.vpcs]
}

# HA module
module "fortigate_ha" {
  source = "fortinetdev/cloud-modules/google//modules/fortigate/fgt_ha"
  prefix = var.prefix
  region = var.region
  zones  = var.zones
  # service_account_email = ""                # This service account will control the cloud function created by this project. If this variable is not specified, the default Google Compute Engine service account is used.
  # hostname              = ""                # FGT hostname. If not set, an FGT's hostname will be its license ID.
  # fgt_password    = "<Your password>"       # If this variable is not set, an FGT's password will be its instance ID.
  machine_type    = "n2-standard-8"
  image_type      = "fortigate-76-payg"
  additional_disk = { size = 30 }
  ha_mode         = var.ha_mode
  network_interfaces = [
    {
      subnet_name   = "${local.prefix}vpc1-subnet"
      elb_ip        = [google_compute_address.elb_ip.address]
      # has_public_ip = true # You can uncomment this line to assign a public IP to this port.
    },
    {
      subnet_name = "${local.prefix}vpc2-subnet"
      ilb_ip      = [google_compute_address.ilb_ip.address]
    },
    {
      subnet_name = "${local.prefix}vpc3-subnet"
    },
    {
      subnet_name   = "${local.prefix}vpc4-subnet"
      has_public_ip = true # This port is used for management. It has public IP just for ease of access, you can also delete this line and access through private IP.
    }
  ]
  ha_port       = "port3"
  mgmt_port     = "port4"
  network_tags  = ["full-access"]
  config_script = <<EOF
config firewall policy
    edit 0
        set name "allow_port2_to_port1"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
end
  EOF

  # If your FortiGate image is BYOL, you can specify the license file or fortiflex token here.
  # license = {
  #   license_file = ["/path/to/license1.lic", "/path/to/license2.lic"]
  # }
  # license = {
  #   fortiflex_token = ["<fortiflex token 1>", "<fortiflex token 2>"]
  # }
  depends_on = [module.vpcs]
}
```

**terraform.tfvars**
```
prefix  = "fgt-ha"
project = "<Your-project-name>"
region  = "us-central1"
zones    = ["us-central1-a", "us-central1-b"]
ha_mode = "fgcp-ap" # "fgcp-ap" or "fgsp-aa"
```

Then, run the commands `terraform init` and `terraform apply` to deploy this project.
