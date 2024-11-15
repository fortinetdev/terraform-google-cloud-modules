output "instance_group_id" {
  value = (
    local.zone_mode == "single"
    ? google_compute_instance_group_manager.manager[0].instance_group
    : google_compute_region_instance_group_manager.manager[0].instance_group
  )
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

output "bucket_name" {
  value       = local.bucket_name
  description = "GCP Bucket name."
}
