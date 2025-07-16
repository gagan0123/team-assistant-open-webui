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
module "networking" {
  source     = "../../modules/networking"
  project_id = var.project_id
  region     = var.region
}

module "open_webui_vm" {
  source                   = "../../modules/compute-engine"
  project_id               = var.project_id
  zone                     = var.zone
  region                   = var.region
  instance_name            = var.instance_name
  machine_type             = "c2-standard-8"
  startup_script           = "../../../assets/startup.sh"
  docker_compose_content   = "../../../assets/docker-compose.yml"
  image_uri                = "${var.region}-docker.pkg.dev/${var.project_id}/open-webui/app:latest"
  depends_on = [
    google_project_service.default,
    module.networking
  ]
}

module "lb_iap" {
  source              = "../../modules/lb-iap"
  project_id          = var.project_id
  lb_name             = "open-webui-staging"
  instance_group_link = module.open_webui_vm.instance_group_link
  domain_name         = var.domain_name
  iap_members         = var.iap_members
  support_email       = var.support_email
  depends_on = [
    module.open_webui_vm
  ]
  oauth_client_id     = var.oauth_client_id
  oauth_client_secret = var.oauth_client_secret
}
