output "ip_address" {
  value = google_filestore_instance.default.networks[0].ip_addresses[0]
}
