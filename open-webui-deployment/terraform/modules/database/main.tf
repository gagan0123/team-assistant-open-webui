# This resource allocates a private IP range for Google's services (like Cloud SQL)
# to connect to your VPC. It only needs to be created once per VPC.
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  name          = "private-ip-for-google-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 16
  network       = var.network_id
}

# This resource establishes the connection between Google's services and your VPC.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "default" {
  project             = var.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  settings {
    tier = "db-g1-small"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }
  # This dependency ensures the VPC peering is complete before the instance is created.
  depends_on = [google_service_networking_connection.private_vpc_connection]
}


resource "google_sql_database" "default" {
  project  = var.project_id
  instance = google_sql_database_instance.default.name
  name     = var.db_name
}

resource "google_sql_user" "default" {
  project  = var.project_id
  instance = google_sql_database_instance.default.name
  name     = var.db_user
  password = var.db_password
}
