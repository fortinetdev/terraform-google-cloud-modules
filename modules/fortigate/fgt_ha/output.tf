output "instance_id_list" {
  value = google_compute_instance_group.fgt_umigs.*.id
}