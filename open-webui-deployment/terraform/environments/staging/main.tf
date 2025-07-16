terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

resource "random_password" "db_password" {
  length  = 16
  special = false
  keepers = {
    # Generate a new password only when the DB instance is replaced
    db_instance = var.db_instance_name
  }
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "open-webui-db-password"
  replication {
    auto {}
  }
  depends_on = [
    module.project_services
  ]
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "db_url" {
  project   = var.project_id
  secret_id = "open-webui-db-url"
  replication {
    auto {}
  }
  depends_on = [
    module.project_services
  ]
}

resource "google_secret_manager_secret_version" "db_url_version" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = "placeholder"
}

resource "google_secret_manager_secret" "redis_url" {
  project   = var.project_id
  secret_id = "open-webui-redis-url"
  replication {
    auto {}
  }
  depends_on = [
    module.project_services
  ]
}

resource "google_secret_manager_secret_version" "redis_url_version" {
  secret      = google_secret_manager_secret.redis_url.id
  secret_data = "placeholder"
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

# This resource gives the new service account the "Cloud SQL Client" role.
resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${module.iam.email}"
}

# This resource gives the new service account the "Redis Viewer" role.
resource "google_project_iam_member" "redis_viewer" {
  project = var.project_id
  role    = "roles/redis.viewer"
  member  = "serviceAccount:${module.iam.email}"
}

# This resource gives the new service account the "Filestore Viewer" role.
resource "google_project_iam_member" "file_viewer" {
  project = var.project_id
  role    = "roles/file.editor"
  member  = "serviceAccount:${module.iam.email}"
}

module "cloud_run" {
  source                  = "../../modules/cloud-run"
  project_id              = var.project_id
  region                  = var.region
  service_name            = var.cloud_run_service_name
  image_uri               = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/app:latest"
  webui_secret_name       = var.webui_secret_name
  service_account_email   = module.iam.email

  vpc_connector_id        = module.networking.connector_id
  filestore_ip_address    = module.filestore.ip_address
  filestore_share_name    = var.filestore_share_name
 
  depends_on = [
    module.project_services,
    module.secret_manager,
    google_secret_manager_secret_iam_member.secret_accessor,
    # Add dependency on all backend modules to ensure they are ready
    module.database,
    module.redis,
    module.filestore
  ]
}

module "networking" {
  source            = "../../modules/networking"
  project_id        = var.project_id
  region            = var.region
  network_name      = var.network_name
  subnet_name       = var.subnet_name
  subnet_ip_range   = var.subnet_ip_range
  connector_name    = var.vpc_connector_name
  depends_on = [
    module.project_services
  ]
}

module "database" {
  source           = "../../modules/database"
  project_id       = var.project_id
  region           = var.region
  instance_name    = var.db_instance_name
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = random_password.db_password.result
  network_id       = module.networking.network_id
  depends_on = [
    module.networking
  ]
}

module "redis" {
  source        = "../../modules/redis"
  project_id    = var.project_id
  region        = var.region
  instance_name = var.redis_instance_name
  network_id    = module.networking.network_id
  private_service_connection = module.database.private_service_connection
  depends_on = [
    module.networking
  ]
}

module "filestore" {
  source          = "../../modules/filestore"
  project_id      = var.project_id
  zone            = "${var.region}-a"
  instance_name   = var.filestore_instance_name
  network_id      = module.networking.network_id
  file_share_name = var.filestore_share_name
  depends_on = [
    module.networking
  ]
}

