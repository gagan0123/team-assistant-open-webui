# Reserve a static external IP address
resource "google_compute_address" "static" {
  project = var.project_id
  name    = "${var.instance_name}-ip"
  region  = var.region
}

# Create a firewall rule to allow HTTP/HTTPS traffic to tagged instances
resource "google_compute_firewall" "webserver" {
  project = var.project_id
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"] # Include 8080 for direct access in MVP
  }

  target_tags   = [var.network_tag]
  source_ranges = ["0.0.0.0/0"] # Allow from any IP
}

# Define the GCE instance
resource "google_compute_instance" "default" {
  project      = var.project_id
  zone         = var.zone
  name         = var.instance_name
  machine_type = var.machine_type
  tags         = [var.network_tag]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = 50
      type  = "pd-balanced"
    }
  }

  # Use the default network interface and attach the static IP
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  # Enable the OS Login feature for better SSH management
  metadata = {
    enable-oslogin = "TRUE"
  }

  # The startup script and docker-compose content are passed in as metadata
  service_account {
    # The default compute service account has permissions to pull from Artifact Registry
    scopes = ["cloud-platform"]
  }

  # This replaces variables in the startup script before running it
  metadata_startup_script = templatefile(var.startup_script, {
    REGION               = split("-", var.zone)[0] # Derives 'us-central1' from 'us-central1-a'
    DOCKER_COMPOSE_YML   = templatefile(var.docker_compose_content, {
      IMAGE_URI = var.image_uri
    })
  })

  # Ensure the firewall rule is created before the instance
  depends_on = [
    google_compute_firewall.webserver
  ]
}

