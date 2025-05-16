locals {
  prefix             = "${var.prefix}-"
  hostname           = var.hostname != "" ? var.hostname : "${local.prefix}instance"
  config_file_script = var.config_file != "" ? file(var.config_file) : ""
  config_script      = var.config_script != "" ? "${var.config_script}\n${local.config_file_script}" : local.config_file_script
  image_lookup       = jsondecode(file("${path.module}/image_lookup.json"))
  image_lookup_query = var.image.product == "fortigate" ? "fortigate-${var.image.lic}-${var.image.arch}" : var.image.product
  image_source = (var.image.source != "" ? var.image.source :
    var.image.family != "" ? data.google_compute_image.fgt_image[0].self_link :
    try(
      local.image_lookup[local.image_lookup_query][var.image.version],
      ""
    )
  )
}

data "google_compute_image" "fgt_image" {
  count   = var.image.family != "" ? 1 : 0
  project = "fortigcp-project-001"
  family  = var.image.family
}

# Additional disks
resource "google_compute_disk" "disk" {
  count = length(var.disks)
  name  = var.disks[count.index].name != "" ? var.disks[count.index].name : "${local.prefix}disk-${count.index}"
  size  = var.disks[count.index].size
  type  = var.disks[count.index].type
  zone  = var.zone
}

# Subnet info
data "google_compute_subnetwork" "subnet_resources" {
  count  = length(var.network_interfaces)
  name   = var.network_interfaces[count.index].subnet_name
  region = var.region
}

# VM
resource "google_compute_instance" "main" {
  name           = local.hostname
  machine_type   = var.machine_type
  zone           = var.zone
  can_ip_forward = true

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = local.image_source
    }
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.disk
    content {
      source = attached_disk.value.self_link
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnetwork = data.google_compute_subnetwork.subnet_resources[network_interface.key].self_link
      network_ip = network_interface.value.private_ip != "" ? network_interface.value.private_ip : null

      dynamic "access_config" {
        for_each = network_interface.value.has_public_ip ? [1] : (network_interface.value.public_ip != "" ? [1] : [])
        content {
          nat_ip = network_interface.value.public_ip != "" ? network_interface.value.public_ip : null
        }
      }
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/bootstrap.tftpl", {
      hostname        = local.hostname
      password        = var.password
      fortiflex_token = var.license.fortiflex_token
      extra_script    = local.config_script
      image_source    = local.image_source
    })
    license = var.license.license_file != "" ? file("${var.license.license_file}") : null
  }

  service_account {
    email  = var.service_account_email != "" ? var.service_account_email : null
    scopes = ["cloud-platform"]
  }
  # For fortiaiops & fortiguest
  dynamic "shielded_instance_config" {
    for_each = (
      can(regex("fortiaiops|fortiguest", local.image_source)) ? [1] : []
    )
    content {
      enable_secure_boot = true
    }
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
