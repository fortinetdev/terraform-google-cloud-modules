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

output "vpc_external" {
  value       = module.vpc_external
  description = "External VPC."
}

output "vpc_internal" {
  value       = module.vpc_internal
  description = "External VPC."
}
