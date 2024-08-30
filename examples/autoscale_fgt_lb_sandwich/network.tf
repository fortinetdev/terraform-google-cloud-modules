module "vpc_external" {
  source = "../../modules/gcp/vpc"

  network_name = "${local.prefix}network-external"

  subnets = [
    {
      name          = "${local.prefix}external"
      region        = var.region
      ip_cidr_range = var.external_subnet
    }
  ]

  firewall_rules = [
    {
      name          = "${local.prefix}external-access"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["external-access"]
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}

module "vpc_internal" {
  source = "../../modules/gcp/vpc"

  network_name = "${local.prefix}network-internal"

  subnets = [
    {
      name          = "${local.prefix}internal"
      region        = var.region
      ip_cidr_range = var.internal_subnet
    }
  ]

  firewall_rules = [
    {
      name          = "${local.prefix}internal-access"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["internal-access"]
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}

# NAT
resource "google_compute_router" "router" {
  name    = "${local.prefix}router"
  region  = var.region
  network = module.vpc_external.network.self_link
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

resource "google_compute_route" "internal_to_external" {
  name         = "${local.prefix}internal-to-external"
  dest_range   = "0.0.0.0/0"
  network      = module.vpc_internal.network.self_link
  next_hop_ilb = module.internal_lb.lb.self_link
  priority     = 100
}

module "vpc_peer" {
  for_each  = { for vpc in var.protected_vpc : vpc.name => vpc }
  source    = "../../modules/gcp/vpc_peer"
  vpc1_name = "${local.prefix}network-internal"
  vpc2_name = each.value.name
  vpc1_to_vpc2 = {
    export_custom_routes = true
  }
  vpc2_to_vpc1 = {
    import_custom_routes = true
  }
  depends_on = [module.vpc_internal]
}
