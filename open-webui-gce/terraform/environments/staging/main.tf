terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

# This resource enables the APIs. It should remain from the first step.
resource "google_project_service" "default" {
  for_each = toset(var.gcp_services)
  project  = var.project_id
  service  = each.key
  disable_on_destroy = false
}

# Call our new compute-engine module
module "open_webui_vm" {
  source                   = "../../modules/compute-engine"
  project_id               = var.project_id
  region                   = var.region
  zone                     = var.zone
  instance_name            = var.instance_name
  machine_type             = "e2-medium"
  
  # We provide paths to our asset files
  startup_script           = "../../../assets/startup.sh"
  docker_compose_content   = "../../../assets/docker-compose.yml"
  
  # Construct the URI to the image we built previously
  image_uri                = "${var.region}-docker.pkg.dev/${var.project_id}/open-webui/app:latest"

  depends_on = [
    google_project_service.default
  ]
}
