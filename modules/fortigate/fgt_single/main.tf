locals {
  prefix             = "${var.prefix}-"
  hostname           = var.hostname != "" ? var.hostname : "${local.prefix}instance"
  config_file_script = var.config_file != "" ? file(var.config_file) : ""
  config_script      = var.config_script != "" ? "${var.config_script}\n${local.config_file_script}" : local.config_file_script
}

# gcloud compute images list --project fortigcp-project-001
data "google_compute_image" "fgt_image" {
  count   = var.image_type != "" ? 1 : 0
  project = "fortigcp-project-001"
  family  = var.image_type
}

# Additional disks
resource "google_compute_disk" "disk" {
  count = var.additional_disk.size != 0 ? 1 : 0
  name  = var.additional_disk.name != "" ? var.additional_disk.name : "${local.prefix}logdisk"
  size  = var.additional_disk.size
  type  = var.additional_disk.type
  zone  = var.zone
}

# Subnet info
data "google_compute_subnetwork" "subnet_resources" {
  count  = length(var.network_interfaces)
  name   = var.network_interfaces[count.index].subnet_name
  region = var.region
}

# Reserve IP
resource "google_compute_address" "private_ips" {
  count        = length(var.network_interfaces)
  name         = "${local.prefix}${var.network_interfaces[count.index].subnet_name}"
  address_type = "INTERNAL"
  address      = var.network_interfaces[count.index].private_ip != "" ? var.network_interfaces[count.index].private_ip : null
  subnetwork   = data.google_compute_subnetwork.subnet_resources[count.index].self_link
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
      image = var.image_source != "" ? var.image_source : data.google_compute_image.fgt_image[0].self_link # One of "image_type" and "image_source" must be provided.
    }
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.disk.*.self_link
    content {
      source = attached_disk.value
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnetwork = data.google_compute_subnetwork.subnet_resources[network_interface.key].self_link
      network_ip = google_compute_address.private_ips[network_interface.key].address

      dynamic "access_config" {
        for_each = var.network_interfaces[network_interface.key].has_public_ip ? [1] : (var.network_interfaces[network_interface.key].public_ip != "" ? [1] : [])
        content {
          nat_ip = var.network_interfaces[network_interface.key].public_ip != "" ? var.network_interfaces[network_interface.key].public_ip : null
        }
      }
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/bootstrap.conf", {
      hostname        = local.hostname
      password        = var.password
      fortiflex_token = var.licensing.fortiflex_token
      extra_script    = local.config_script
    })
    license = var.licensing.license_file != "" ? file("${var.licensing.license_file}") : null
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
