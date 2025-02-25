locals {
  prefix                = "${var.prefix}-"
  fgt_password          = (local.use_fgt_passwd && var.fgt_password == "") ? random_password.fgt_password[0].result : var.fgt_password
  autoscale_psksecret   = var.cloud_function.autoscale_psksecret == "" ? random_password.autoscale_psksecret[0].result : var.cloud_function.autoscale_psksecret
  bucket_name           = "${var.prefix}-bucket-${random_string.bucket_id.result}"
  zone_mode             = (var.zone != "" && length(var.zones) == 0) ? "single" : "multiple"
  iam_member            = var.service_account_email == "" ? data.google_compute_default_service_account.default.member : data.google_service_account.iam[0].member
  service_account_email = var.service_account_email == "" ? data.google_compute_default_service_account.default.email : var.service_account_email
  use_fgt_passwd        = !var.special_behavior.disable_secret_manager
  use_fortiflex_passwd  = !var.special_behavior.disable_secret_manager && var.cloud_function.fortiflex.password != ""
  image_source          = var.image_source != "" ? var.image_source : data.google_compute_image.fgt_image[0].self_link # One of "image_type" and "image_source" must be provided.
  image_source_hash     = substr(sha1(local.image_source), 0, 8)
}

resource "random_password" "fgt_password" {
  count   = (local.use_fgt_passwd && var.fgt_password == "") ? 1 : 0
  length  = 16
  special = false
}

resource "random_password" "autoscale_psksecret" {
  count   = var.cloud_function.autoscale_psksecret == "" ? 1 : 0
  length  = 16
  special = false
}

# IAM
data "google_compute_default_service_account" "default" {
}

data "google_service_account" "iam" {
  count      = var.service_account_email != "" ? 1 : 0
  account_id = var.service_account_email
}

resource "google_storage_bucket_iam_member" "bucket_access" {
  bucket = google_storage_bucket.gcf_bucket.name
  role   = "roles/storage.admin"
  member = local.iam_member
}

resource "google_secret_manager_secret_iam_member" "fortiflex_password" {
  count     = local.use_fortiflex_passwd ? 1 : 0
  secret_id = google_secret_manager_secret.fortiflex_password[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.iam_member
}

resource "google_secret_manager_secret_iam_member" "instance_password" {
  count     = local.use_fgt_passwd ? 1 : 0
  secret_id = google_secret_manager_secret.instance_password[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.iam_member
}

# Subnet
data "google_compute_subnetwork" "subnet_resources" {
  count  = length(var.network_interfaces)
  name   = var.network_interfaces[count.index].subnet_name
  region = var.region
}

# Image
data "google_compute_image" "fgt_image" {
  count   = var.image_type != "" ? 1 : 0
  project = "fortigcp-project-001"
  family  = var.image_type
}

# VM
resource "google_compute_region_instance_template" "main" {
  # If the image source changes, this template will be recreated.
  name           = "${local.prefix}template-${local.image_source_hash}"
  region         = var.region
  machine_type   = var.machine_type
  can_ip_forward = true

  tags = var.network_tags

  disk {
    boot         = true
    source_image = local.image_source
  }

  dynamic "disk" {
    for_each = var.additional_disk.size != 0 ? [1] : []
    content {
      boot         = false
      auto_delete  = true
      disk_type    = var.additional_disk.type
      disk_size_gb = var.additional_disk.size
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnetwork = data.google_compute_subnetwork.subnet_resources[network_interface.key].self_link
      dynamic "access_config" {
        for_each = var.network_interfaces[network_interface.key].has_public_ip ? [1] : []
        content {}
      }
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/bootstrap.conf", {
      hostname      = var.hostname
      config_script = var.config_script
    })
  }

  service_account {
    email  = local.service_account_email
    scopes = ["cloud-platform"]
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      metadata
    ]
  }
  depends_on = [
    google_cloudfunctions2_function.init_instance,
    time_sleep.wait_after_function_creation,
    time_sleep.wait_before_function_destruction,
  ]
}

# This health check is for autohealing.
# Because this health check will replace unhealthy instances, you may want to increase the
# check interval to at least 10 seconds and the unhealthy threshold to at least 3 times so your instances aren't replaced too often.
resource "google_compute_region_health_check" "autohealing" {
  count               = var.autoscaler.autohealing.health_check_port != 0 ? 1 : 0
  name                = "${local.prefix}autoheal"
  region              = var.region
  timeout_sec         = var.autoscaler.autohealing.timeout_sec
  check_interval_sec  = var.autoscaler.autohealing.check_interval_sec
  unhealthy_threshold = var.autoscaler.autohealing.unhealthy_threshold
  http_health_check {
    port = var.autoscaler.autohealing.health_check_port
  }
}

# Single zone
resource "google_compute_instance_group_manager" "manager" {
  count              = local.zone_mode == "single" ? 1 : 0
  name               = "${local.prefix}instance-group"
  base_instance_name = "${local.prefix}group"
  zone               = var.zone
  version {
    instance_template = google_compute_region_instance_template.main.self_link
  }
  dynamic "auto_healing_policies" {
    for_each = var.autoscaler.autohealing.health_check_port != 0 ? [1] : []
    content {
      health_check      = google_compute_region_health_check.autohealing[0].id
      initial_delay_sec = var.autoscaler.cooldown_period
    }
  }
}

resource "google_compute_autoscaler" "autoscaler" {
  count  = local.zone_mode == "single" ? 1 : 0
  name   = "${local.prefix}autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.manager[0].id

  autoscaling_policy {
    max_replicas    = var.autoscaler.max_instances
    min_replicas    = var.autoscaler.min_instances
    cooldown_period = var.autoscaler.cooldown_period

    cpu_utilization {
      target = var.autoscaler.cpu_utilization
    }
  }
}

# Multiple zones
resource "google_compute_region_instance_group_manager" "manager" {
  count                     = local.zone_mode == "multiple" ? 1 : 0
  name                      = "${local.prefix}regional-instance-group"
  base_instance_name        = "${local.prefix}group"
  region                    = var.region
  distribution_policy_zones = length(var.zones) > 0 ? var.zones : null # If user don't specify var.zones, let GCP API select it.
  version {
    instance_template = google_compute_region_instance_template.main.self_link
  }
  dynamic "auto_healing_policies" {
    for_each = var.autoscaler.autohealing.health_check_port != 0 ? [1] : []
    content {
      health_check      = google_compute_region_health_check.autohealing[0].id
      initial_delay_sec = var.autoscaler.cooldown_period
    }
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  count  = local.zone_mode == "multiple" ? 1 : 0
  name   = "${local.prefix}regional-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.manager[0].id

  autoscaling_policy {
    max_replicas    = var.autoscaler.max_instances
    min_replicas    = var.autoscaler.min_instances
    cooldown_period = var.autoscaler.cooldown_period

    dynamic "scale_in_control" {
      for_each = var.autoscaler.scale_in_control_sec != 0 ? [1] : []
      content {
        max_scaled_in_replicas {
          fixed = 1
        }
        time_window_sec = var.autoscaler.scale_in_control_sec
      }
    }

    cpu_utilization {
      target = var.autoscaler.cpu_utilization
    }
  }
}
