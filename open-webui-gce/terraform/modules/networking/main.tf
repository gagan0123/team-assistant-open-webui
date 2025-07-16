
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "nat-router"
  network = "default"
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "nat-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
