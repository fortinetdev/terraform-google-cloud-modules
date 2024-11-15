locals {
  prefix                 = var.prefix == "" ? "" : "${var.prefix}-"
  health_check_self_link = var.health_check.use_existing_health_check ? var.health_check.existing_self_link : google_compute_region_health_check.default[0].self_link
}

resource "google_compute_region_health_check" "default" {
  count              = var.health_check.use_existing_health_check ? 0 : 1
  name               = "${local.prefix}health-check"
  region             = var.region
  timeout_sec        = var.health_check.timeout_sec
  check_interval_sec = var.health_check.check_interval_sec
  tcp_health_check {
    port = var.health_check.port
  }
}

resource "google_compute_region_backend_service" "backend" {
  name                  = "${local.prefix}backend"
  region                = var.region
  load_balancing_scheme = var.schema
  network               = var.schema == "INTERNAL" ? var.ilb.network_id : null
  session_affinity      = var.session_affinity
  protocol              = var.backend_protocol
  health_checks         = [local.health_check_self_link]
  dynamic "backend" {
    for_each = var.backends_list
    content {
      balancing_mode = "CONNECTION" # For google provider 6.0 compatibility issue
      group = backend.value
    }
  }
}

resource "google_compute_forwarding_rule" "lb" {
  name                  = "${local.prefix}lb"
  region                = var.region
  ip_address            = var.front_end_ip != "" ? var.front_end_ip : null
  ip_protocol           = var.frontend_protocol
  load_balancing_scheme = var.schema
  network               = var.schema == "INTERNAL" ? var.ilb.network_id : null
  subnetwork            = var.schema == "INTERNAL" ? var.ilb.subnet_id : null
  backend_service       = google_compute_region_backend_service.backend.self_link
  network_tier          = var.network_tier

  ports      = var.use_all_ports == true || length(var.ports) == 0 ? null : var.ports
  port_range = var.use_all_ports == true || length(var.ports) > 0 || var.port_range == "" ? null : var.port_range
  all_ports  = var.use_all_ports == true || (var.use_all_ports == false && length(var.ports) == 0 && var.port_range == "")
}
