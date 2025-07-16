output "network_id" {
  value = google_compute_network.main.id
}
output "connector_id" {
  value = google_vpc_access_connector.main.id
}

