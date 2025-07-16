resource "google_redis_instance" "default" {
  project           = var.project_id
  name              = var.instance_name
  region            = var.region
  tier              = "BASIC"
  memory_size_gb    = 1
  authorized_network = var.network_id
  connect_mode      = "PRIVATE_SERVICE_ACCESS"
  depends_on = [
    var.private_service_connection
  ]
}