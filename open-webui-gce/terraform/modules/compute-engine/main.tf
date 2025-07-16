# Firewall rule is now more restrictive.
# It allows traffic ONLY from the Google Load Balancer and Health Check IP ranges.
resource "google_compute_firewall" "allow_lb_health_check" {
  project = var.project_id
  name    = "allow-lb-and-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"] # The internal port our service runs on
  }

  target_tags   = [var.network_tag]
  # These are the official IP ranges for all Google front ends and health checkers.
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# The GCE instance now has NO public IP address.
resource "google_compute_instance" "default" {
  project                   = var.project_id
  zone                      = var.zone
  name                      = var.instance_name
  machine_type              = var.machine_type
  tags                      = [var.network_tag]
  allow_stopping_for_update = true
  desired_status            = "RUNNING"


  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = 50
      type  = "pd-balanced"
    }
  }

  # NO 'access_config' block means NO public IP.
  network_interface {
    network = "default"
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile(var.startup_script, {
    REGION               = split("-", var.zone)[0]
    DOCKER_COMPOSE_YML   = templatefile(var.docker_compose_content, {
      IMAGE_URI = var.image_uri
    })
  })

  depends_on = [
    google_compute_firewall.allow_lb_health_check
  ]
}

# Create an Unmanaged Instance Group to hold our single VM.
# This is required by the Load Balancer's backend service.
resource "google_compute_instance_group" "default" {
  project   = var.project_id
  zone      = var.zone
  name      = "${var.instance_name}-ig"
  instances = [google_compute_instance.default.self_link]

  named_port {
    name = "http"
    port = "8080"
  }
}
