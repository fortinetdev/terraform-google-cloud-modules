locals {
  query_vpc1_data = var.vpc1_network == "" ? true : false
  query_vpc2_data = var.vpc2_network == "" ? true : false
  prefix          = var.prefix == "" ? "" : "${var.prefix}-"
}

data "google_compute_network" "vpc1" {
  count = local.query_vpc1_data ? 1 : 0
  name  = var.vpc1_name
}

data "google_compute_network" "vpc2" {
  count = local.query_vpc2_data ? 1 : 0
  name  = var.vpc2_name
}

resource "google_compute_network_peering" "vpc1_to_vpc2" {
  name                                = "${local.prefix}${var.vpc1_name}-to-${var.vpc2_name}"
  network                             = local.query_vpc1_data ? data.google_compute_network.vpc1[0].self_link : var.vpc1_network
  peer_network                        = local.query_vpc2_data ? data.google_compute_network.vpc2[0].self_link : var.vpc2_network
  export_custom_routes                = var.vpc1_to_vpc2.export_custom_routes
  import_custom_routes                = var.vpc1_to_vpc2.import_custom_routes
  export_subnet_routes_with_public_ip = var.vpc1_to_vpc2.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.vpc1_to_vpc2.import_subnet_routes_with_public_ip
}

# terraform apply -parallelism=1
resource "google_compute_network_peering" "vpc2_to_vpc1" {
  name                                = "${local.prefix}${var.vpc2_name}-to-${var.vpc1_name}"
  network                             = local.query_vpc2_data ? data.google_compute_network.vpc2[0].self_link : var.vpc2_network
  peer_network                        = local.query_vpc1_data ? data.google_compute_network.vpc1[0].self_link : var.vpc1_network
  export_custom_routes                = var.vpc2_to_vpc1.export_custom_routes
  import_custom_routes                = var.vpc2_to_vpc1.import_custom_routes
  export_subnet_routes_with_public_ip = var.vpc2_to_vpc1.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.vpc2_to_vpc1.import_subnet_routes_with_public_ip
  depends_on                          = [google_compute_network_peering.vpc1_to_vpc2]
}
