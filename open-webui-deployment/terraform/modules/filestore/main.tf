resource "google_filestore_instance" "default" {
  project  = var.project_id
  name     = var.instance_name
  location = var.zone
  tier     = "BASIC_HDD"
  file_shares {
    capacity_gb = 1024
    name        = var.file_share_name
  }
  networks {
    network = var.network_id
    modes   = ["MODE_IPV4"]
    reserved_ip_range = "AUTO_RESERVED_IP_RANGE"
  }
}
