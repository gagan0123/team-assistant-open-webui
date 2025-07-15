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
  region  = var.region
}

module "project_services" {
  source       = "../../modules/project-services"
  project_id   = var.project_id
  gcp_services = var.gcp_services
}

module "artifact_registry" {
  source        = "../../modules/artifact-registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = var.repository_id
  depends_on = [
    module.project_services
  ]
}

module "secret_manager" {
  source     = "../../modules/secret-manager"
  project_id = var.project_id
  secret_id  = var.webui_secret_name
  depends_on = [
    module.project_services
  ]
}

module "iam" {
  source             = "../../modules/iam"
  project_id         = var.project_id
  service_account_id = var.service_account_id
  display_name       = "Open WebUI Application Service Account"
}

# This resource gives the new service account the "Secret Accessor" role for our specific secret.
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  project   = var.project_id
  secret_id = module.secret_manager.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.iam.email}"
}

module "cloud_run" {
  source         = "../../modules/cloud-run"
  project_id     = var.project_id
  region         = var.region
  service_name   = var.cloud_run_service_name
  image_uri      = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/app:latest"
  webui_secret_name = var.webui_secret_name
  service_account_email = module.iam.email
  depends_on = [
    module.project_services,
    module.secret_manager,
    google_secret_manager_secret_iam_member.secret_accessor
  ]
}
