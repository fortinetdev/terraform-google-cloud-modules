output "instance" {
  value = google_compute_instance.main
}
output "instance_name" {
  value = google_compute_instance.main.name
}
output "instance_id" {
  value = google_compute_instance.main.instance_id
  description = "The instance id of the VM. This is the default password for FortiGate, FortiAnalyzer and FortiManager."
}
output "default_password" {
  value = var.password == "" ? google_compute_instance.main.instance_id : var.password
  description = "The default admin password is the instance_id if not set (Only for FortiGate, FortiAnalyzer and FortiManager)."
}
output "private_ips" {
  value = [for nic in google_compute_instance.main.network_interface : nic.network_ip ]
  description = "List of private IPs for each network interface."
}

output "public_ips" {
  value = [
    for nic in google_compute_instance.main.network_interface :
    (
      length(nic.access_config) > 0 ?
      (
        try(nic.access_config[0].nat_ip, "")
      ) :
      ""
    )
  ]
  description = "List of public IPs for each network interface (or empty string if none)"
}

output "image_source" {
  value = local.image_source
  description = "The image source of the VM."
    precondition {
    condition     = local.image_source != ""
    error_message = "No valid image source was found. You must specify one of the following: image.source, image.family, or a known combination of image.product and image.version."
  }
}