output "network" {
  value       = google_compute_network.vpc
  description = "VPC Network."
}

output "subnets" {
  value       = google_compute_subnetwork.subnets
  description = "Subnets."
}
