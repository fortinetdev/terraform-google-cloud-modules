output "default_password" {
  value = var.password == "" ? google_compute_instance.main.instance_id : var.password
}
output "instance_name" {
  value = google_compute_instance.main.name
}
output "instance" {
  value = google_compute_instance.main
}
output "instance_id" {
  value = google_compute_instance.main.instance_id
}
output "port_ips" {
  value = google_compute_address.private_ips
}