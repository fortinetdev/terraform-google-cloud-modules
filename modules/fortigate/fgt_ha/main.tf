locals {
  prefix             = "${var.prefix}-"
  hostname           = var.hostname != "" ? var.hostname : "${local.prefix}instance"
  config_file_script = var.config_file != "" ? file(var.config_file) : ""
  config_script      = var.config_script != "" ? "${var.config_script}\n${local.config_file_script}" : local.config_file_script
  zones              = length(var.zones) > 0 ? var.zones : data.google_compute_zones.zones_in_region[0].names
  image_source       = var.image_source != "" ? var.image_source : data.google_compute_image.fgt_image[0].self_link # One of "image_type" and "image_source" must be provided.

  mgmt_port = var.mgmt_port != null ? var.mgmt_port : "port${length(var.network_interfaces)}"
  ha_port   = var.ha_port != null ? var.ha_port : "port${length(var.network_interfaces)}"
  network_interfaces_map = zipmap(
    [for i in range(length(var.network_interfaces)) : "port${i + 1}"],
    var.network_interfaces
  )
  subnets_info = data.google_compute_subnetwork.subnet_resources
  private_ips  = [google_compute_address.private_ips_1, google_compute_address.private_ips_2]
  ha_password = var.ha_password != "" ? var.ha_password : "example_passwd"
}

data "google_compute_zones" "zones_in_region" {
  count = length(var.zones) == 0 ? 1 : 0
}

# gcloud compute images list --project fortigcp-project-001
data "google_compute_image" "fgt_image" {
  count   = var.image_type != "" ? 1 : 0
  project = "fortigcp-project-001"
  family  = var.image_type
}

# Subnet info
data "google_compute_subnetwork" "subnet_resources" {
  for_each = local.network_interfaces_map

  name   = each.value.subnet_name
  region = var.region
}

# Additional disks
resource "google_compute_disk" "disk" {
  count = var.additional_disk.size != 0 ? 2 : 0
  name  = "${local.prefix}logdisk-${count.index}"
  size  = var.additional_disk.size
  type  = var.additional_disk.type
  zone  = local.zones[count.index]
}

# Reserve IP
resource "google_compute_address" "private_ips_1" {
  for_each     = local.network_interfaces_map
  name         = "${local.prefix}${each.value.subnet_name}-1"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet_resources[each.key].self_link
}

resource "google_compute_address" "private_ips_2" {
  for_each     = local.network_interfaces_map
  name         = "${local.prefix}${each.value.subnet_name}-2"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet_resources[each.key].self_link
  depends_on   = [google_compute_address.private_ips_1]
}

resource "google_compute_instance" "fgts" {
  count          = 2
  name           = "${local.hostname}-${count.index + 1}"
  machine_type   = var.machine_type
  zone           = local.zones[count.index]
  can_ip_forward = true

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = local.image_source
    }
  }

  dynamic "attached_disk" {
    for_each = var.additional_disk.size != 0 ? [1] : []
    content {
      source = google_compute_disk.disk[count.index].name
    }
  }

  dynamic "network_interface" {
    for_each = local.network_interfaces_map
    content {
      subnetwork = data.google_compute_subnetwork.subnet_resources[network_interface.key].self_link
      network_ip = local.private_ips[count.index][network_interface.key].address

      dynamic "access_config" {
        for_each = network_interface.value.has_public_ip ? [1] : []
        content {
        }
      }
    }
  }

  metadata = {
    license = var.license.license_file[count.index] != "" ? file("${var.license.license_file[count.index]}") : null
    user-data = templatefile("${path.module}/bootstrap.conf", {
      hostname           = "${local.hostname}-${count.index + 1}"
      password           = var.fgt_password
      network_interfaces = local.network_interfaces_map
      subnets_info       = local.subnets_info
      private_ips        = local.private_ips[count.index]
      mgmt_port          = local.mgmt_port
      ha_port            = local.ha_port
      ha_password        = local.ha_password
      fortiflex_token    = var.license.fortiflex_token[count.index]
      ha_mode            = var.ha_mode
      index              = count.index
      priority           = (count.index + 1) % 2
      peerip             = "${local.private_ips[(count.index + 1) % 2][local.ha_port].address}"
      netmask            = cidrnetmask(local.subnets_info[local.ha_port].ip_cidr_range)
      config_script      = local.config_script
    })
  }

  service_account {
    email  = var.service_account_email != "" ? var.service_account_email : null
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}


resource "google_compute_instance_group" "fgt_umigs" {
  count     = 2
  name      = "${local.prefix}umig-${count.index+1}"
  zone      = local.zones[count.index]
  instances = [google_compute_instance.fgts[count.index].self_link]
  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "https"
    port = 443
  }
}
