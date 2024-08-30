output "health_check_self_link" {
  value       = local.health_check_self_link
  description = "The self link of health check resource."
}
output "lb" {
  value       = google_compute_forwarding_rule.lb
  description = "The load balancer resource."
}
output "front_end_ip" {
  value       = google_compute_forwarding_rule.lb.ip_address
  description = "IP address of the front end."
}
