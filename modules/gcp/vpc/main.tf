locals {
  firewall_rules = { for rule in var.firewall_rules : rule.name => rule }
  subnets        = { for subnet in var.subnets : subnet.name => subnet }
}

resource "google_compute_network" "vpc" {
  name                            = var.network_name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = var.vpc.delete_default_route
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = local.subnets
  name                     = each.value.name
  region                   = each.value.region
  network                  = google_compute_network.vpc.self_link
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_ip_google_access
}

resource "google_compute_firewall" "firewall_rules" {
  for_each                = local.firewall_rules
  name                    = each.value.name
  description             = each.value.description
  direction               = each.value.direction
  network                 = google_compute_network.vpc.self_link
  source_ranges           = lookup(each.value, "source_ranges", null)
  destination_ranges      = lookup(each.value, "destination_ranges", null)
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
  priority                = each.value.priority

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}
