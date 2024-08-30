output "instance_group_id" {
  value       = google_compute_instance_group_manager.manager.instance_group
  description = "The full URL of the instance group created by this module."
}

output "fgt_password" {
  value       = local.fgt_password
  sensitive   = true
  description = "Password for all FGTs."
}

output "autoscale_psksecret" {
  value       = local.autoscale_psksecret
  sensitive   = true
  description = "The secret key used to synchronize information between FortiGates."
}
