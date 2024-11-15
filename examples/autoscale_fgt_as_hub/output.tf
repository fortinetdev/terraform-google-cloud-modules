output "fgt_username" {
  value       = "admin"
  description = "Default username for all FGTs."
}

output "fgt_password" {
  value       = module.fortigate_asg.fgt_password
  sensitive   = true
  description = "Password for all FGTs."
}

output "autoscale_psksecret" {
  value       = module.fortigate_asg.autoscale_psksecret
  sensitive   = true
  description = "The secret key used to synchronize information between FortiGates."
}

output "bucket_name" {
  value       = module.fortigate_asg.bucket_name
  description = "GCP Bucket name."
}

output "ilb_ips" {
  description = "List of Internal Load Balancer IPs. Empty \"\" means no Internal Load Balancer IP for this port."
  value       = [for nic in local.nic_list : nic.ilb_ip]
}
